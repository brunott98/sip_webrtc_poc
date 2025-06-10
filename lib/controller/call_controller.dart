
import 'dart:async';
import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:pocsip/util/config/sip_config.dart';
import 'package:sip_ua/sip_ua.dart';



class CallController extends GetxController implements SipUaHelperListener{

  SIPUAHelper? currentSipUaHelper;
  String? currentRamal;


  CallController({required SIPUAHelper sipUaHelper}) {
    currentSipUaHelper = sipUaHelper;
    currentSipUaHelper!.addSipUaHelperListener(this);
  }




  ///States
  final Rx<RegistrationStateEnum> registrationState = RegistrationStateEnum.NONE.obs;
  final Rx<TransportStateEnum> transportState = TransportStateEnum.NONE.obs;
  final Rx<CallStateEnum> callState = CallStateEnum.NONE.obs;
  final Rxn<Call> currentCall = Rxn<Call>();


  ///Call data
  final Rx<MediaStream?>            remoteStream      = Rx<MediaStream?>(null);
  final Rx<MediaStream?>            localStream       = Rx<MediaStream?>(null);


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

    registrationState.value = state.state ?? RegistrationStateEnum.NONE;

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

    transportState.value = state.state;
    switch (state.state) {
      case TransportStateEnum.CONNECTED:
        //OK
        break;
      case TransportStateEnum.CONNECTING:
        //OK
        break;
      case TransportStateEnum.DISCONNECTED: //Websocket and sip server lost conecction
        registrationState.value = RegistrationStateEnum.UNREGISTERED;
        break;
      default:
        break;
    }

  }

  @override
  void callStateChanged(Call call, CallState state) {

    currentCall.value =  call;
    callState.value = state.state;

    if (state.state == CallStateEnum.FAILED ||
        state.state == CallStateEnum.ENDED) {
      clear();
    }else if(state.state == CallStateEnum.STREAM){
      if (state.originator == 'remote' && remoteStream.value != state.stream) remoteStream.value = state.stream;
      if (state.originator == 'local'  && localStream.value  != state.stream)  localStream.value  = state.stream;
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
    required bool withVideo}) async {

    if (currentCall.value != null && currentRamal == null) return;
    if(ramalTarget == currentRamal) return;

    //First check if we are connected to SIP server
    if (registrationState.value == RegistrationStateEnum.REGISTERED) {
      if(withVideo){
        await startVideoCall(ramalTarget);
      } else{
        await startVoiceCall(ramalTarget);
      }
    }
  }


  Future <void> startVoiceCall(String ramalTarget) async {

    try{


      final uri = 'sip:$ramalTarget@${SipConfig.domain}';

      final isCalling =
      await currentSipUaHelper!.call(uri, voiceOnly: true);

      if(isCalling){
      } else{
        log("voiceCall| calling was impossible");
      }

    } catch(e){
      log('voiceCall| $e');
    }

  }


  Future<void> startVideoCall(String ramalTarget) async {

    try{

      final uri = 'sip:$ramalTarget@${SipConfig.domain}';



      final isCalling = await currentSipUaHelper!.call(uri,
          voiceOnly: false);

      if(isCalling){
      } else{
        log("videoCall| calling was impossible");
      }

    } catch(e){
      log('videoCall| $e');
    }

  }


  Future<void> acceptCall({required bool withVideo}) async {

    try{

      final options = currentSipUaHelper!.buildCallOptions(withVideo);
      currentCall.value!.answer(options);

    }catch(e){
      log('acceptCall| $e');
    }

  }


  Future<void> endCall() async {
    if (currentCall.value == null) return;

    currentCall.value!.hangup();
    clear();
  }


  void clear() {
    remoteStream.value?.getTracks().forEach((t) => t.stop());
    localStream.value?.getTracks().forEach((t) => t.stop());
    remoteStream.value = null;
    localStream.value  = null;
    currentCall.value  = null;
    callState.value    = CallStateEnum.NONE;
  }

  ///--------------------------------------


  ///-------------------Connection methods-------------------
  //Login: navigate after a successful register on maximum time limit
  Future<bool> waitForRegistration({
    Duration timeout = const Duration(seconds: 7)}) {

    if (registrationState.value ==
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
