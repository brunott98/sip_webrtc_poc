
import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:pocsip/util/config/sip_config.dart';
import 'package:sip_ua/sip_ua.dart';



class CallController extends GetxController implements SipUaHelperListener{

  SIPUAHelper? currentSipUaHelper;
  String? currentRamal;
  final Rxn<Call> currentCall = Rxn<Call>();


  CallController({required SIPUAHelper sipUaHelper}) {
    currentSipUaHelper = sipUaHelper;
    currentSipUaHelper!.addSipUaHelperListener(this);
  }


  ///General States
  final Rx<RegistrationStateEnum> currentRegistrationStateEnum = RegistrationStateEnum.NONE.obs;
  final Rx<TransportStateEnum> currentTransportStateEnum = TransportStateEnum.NONE.obs;
  final Rx<CallStateEnum> currentCallStateEnum = CallStateEnum.NONE.obs;


  //To avoid fast navigation to onCallScreen
  final Rx<CallStateEnum> _previousCallStateEnum = CallStateEnum.NONE.obs;

  bool get hasBeenConfirmed =>
      _previousCallStateEnum.value == CallStateEnum.CONFIRMED ||
          currentCallStateEnum.value == CallStateEnum.CONFIRMED;


  ///Call data
  final Rxn<MediaStream> localStream  = Rxn<MediaStream>();
  final Rxn<MediaStream> remoteStream = Rxn<MediaStream>();

  final Rxn<RTCVideoRenderer> remoteRenderer = Rxn<RTCVideoRenderer>();
  final Rxn<RTCVideoRenderer> localRenderer  = Rxn<RTCVideoRenderer>();



  ///Login completer
  Completer<bool>? _registerCompleter;


  ///Setters
  void setCurrentRamal(String userCurrentRamal) {
    currentRamal = userCurrentRamal;
  }


  ///Overrides
  //SIP Server
  @override
  void registrationStateChanged(RegistrationState state) {

    currentRegistrationStateEnum.value = state.state ?? RegistrationStateEnum.NONE;

    if (_registerCompleter != null && !_registerCompleter!.isCompleted) {
      switch (state.state) {
        case RegistrationStateEnum.REGISTERED:
          _registerCompleter!.complete(true);
          break;
        case RegistrationStateEnum.REGISTRATION_FAILED:
          _registerCompleter!.complete(false);
          break;
        default:
          break;
      }
    }

  }

  //Websocket connection with SIP Server
  @override
  void transportStateChanged(TransportState state) {

    currentTransportStateEnum.value = state.state;
    switch (state.state) {
      case TransportStateEnum.CONNECTED:
        //OK
        break;
      case TransportStateEnum.CONNECTING:
        //OK
        break;
      case TransportStateEnum.DISCONNECTED: //Websocket and sip server lost conecction
        currentRegistrationStateEnum.value = RegistrationStateEnum.UNREGISTERED;
        break;
      default:
        break;
    }

  }

  @override
  void callStateChanged(Call call, CallState state) {
    currentCall.value = call;

    _previousCallStateEnum.value = currentCallStateEnum.value;
    currentCallStateEnum.value = state.state;

    if (state.state == CallStateEnum.FAILED ||
        state.state == CallStateEnum.ENDED) {
      clear();
    } else if (state.state == CallStateEnum.STREAM) {
      _handleStreams(state);
    }
  }


  // TODO: implement onNewReinvite
  @override
  void onNewReinvite(ReInvite event) {

  }

  // TODO: implement onNewMessage
  @override
  void onNewMessage(SIPMessageRequest msg) {

  }

  // TODO: implement onNewNotify
  @override
  void onNewNotify(Notify ntf) {

  }


  ///-------------------Call methods-------------------



  Future<void> startCall({ required String ramalTarget,
    required bool voiceOnly}) async {

    if (currentCall.value != null && currentRamal == null) return;
    if(ramalTarget == currentRamal) return;

    //First check if we are connected to SIP server
    if (currentRegistrationStateEnum.value == RegistrationStateEnum.REGISTERED) {
      if(voiceOnly){
        await startVoiceCall(ramalTarget);
      } else{
        await startVideoCall(ramalTarget);
      }
    }
  }

  Future <void> startVoiceCall(String ramalTarget) async {

    try{

      final uri = 'sip:$ramalTarget@${SipConfig.domain}';

      var mediaConstraints = <String, dynamic>{
        'audio': true,
        'video': false
      };

      MediaStream mediaStream;

      mediaStream = await rtc.navigator.mediaDevices.getUserMedia(mediaConstraints);

      final isCalling =
      await currentSipUaHelper!.call(uri, voiceOnly: true, mediaStream: mediaStream);


      if(isCalling){
      } else{
        log("voiceCall| calling was impossible");
      }

    } catch(e){
      log('voiceCall| $e');
    }

  }


  Future<void> startVideoCall(String ramalTarget) async {
    try {

      final uri = 'sip:$ramalTarget@${SipConfig.domain}';

      final mediaConstraints = <String, dynamic>{
        'audio': true,
        'video': {
          'mandatory': <String, dynamic>{
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
        }
      };

      final mediaStream = await rtc.navigator.mediaDevices.getUserMedia(
       mediaConstraints
      );

      final isCalling = await currentSipUaHelper!.call(
        uri,
        voiceOnly: false,
        mediaStream: mediaStream,
      );

      if(isCalling){
      } else{
        log("videoCall| calling was impossible");
      }

    } catch(e){
      log('videoCall| $e');
    }

  }


  void acceptCall() async {

    bool remoteHasVideo = currentCall.value!.remote_has_video;

    final mediaConstraints = <String, dynamic>{

      'audio': true,
      'video': remoteHasVideo
          ? {
        'mandatory': <String, dynamic>{
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': <dynamic>[],
      }
          : false
    };

    MediaStream mediaStream;

    if (kIsWeb && remoteHasVideo) {
      mediaStream =
      await rtc.navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      MediaStream userStream =
      await rtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
      mediaStream.addTrack(userStream.getAudioTracks()[0], addToNative: true);
    } else {
      if (!remoteHasVideo) {
        mediaConstraints['video'] = false;
      }
      mediaStream = await rtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
    }

    currentCall.value!.answer(currentSipUaHelper!.buildCallOptions(!remoteHasVideo),
        mediaStream: mediaStream);

  }


  Future<void> endCall() async {
    if (currentCall.value == null) return;
    currentCall.value!.hangup();
    clear();
  }


  ///Data Stream Handlers

  Future<void> ensureRenderers() async {
    if (remoteRenderer.value == null) {
      remoteRenderer.value = RTCVideoRenderer();
      await remoteRenderer.value!.initialize();
    }
    if (localRenderer.value == null) {
      localRenderer.value = RTCVideoRenderer();
      await localRenderer.value!.initialize();
    }
  }

  void _handleStreams(CallState event) async {

    await ensureRenderers();
    MediaStream? stream = event.stream;
    if (event.originator == 'local') {
      if (localRenderer.value != null) {
        localRenderer.value!.srcObject = stream;
      }

      if (!kIsWeb &&
          !WebRTC.platformIsDesktop &&
          event.stream
              ?.getAudioTracks()
              .isNotEmpty == true) {
        event.stream
            ?.getAudioTracks()
            .first
            .enableSpeakerphone(false);
      }
      localStream.value  = stream;
    }
    if (event.originator == 'remote') {
      if (remoteRenderer.value != null) {
        remoteRenderer.value!.srcObject = stream;
      }
      remoteStream.value = stream;
    }

  }


  void clear() {

    log("-----------called Clear-----------");
    if(localStream.value == null) return;
    localStream.value?.getTracks().forEach((track) {
      track.stop();
    });
    localStream.value!.dispose();
    localStream.value = null;

    _previousCallStateEnum.value = CallStateEnum.NONE;
    currentCallStateEnum.value   = CallStateEnum.NONE;
    currentCall.value = null;
  }



  ///-------------------Connection methods-------------------
  //Login: navigate after a successful register on maximum time limit
  Future<bool> waitForRegistration({
    Duration timeout = const Duration(seconds: 7)}) {

    if (currentRegistrationStateEnum.value ==
        RegistrationStateEnum.REGISTERED) {
      return Future.value(true);
    }
    _registerCompleter ??= Completer<bool>();
    return _registerCompleter!.future
        .timeout(timeout, onTimeout: () => false);
  }

  void disconnect() {
    clear();
    currentRamal = null;
    currentSipUaHelper?.removeSipUaHelperListener(this);
    currentSipUaHelper?.stop();
  }


}
