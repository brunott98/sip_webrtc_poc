import 'dart:developer';
import 'package:get/get.dart';
import 'package:pocsip/controller/call/wrtc_controller.dart';
import 'package:pocsip/model/user_model.dart';
import 'package:pocsip/util/config/sip_config.dart';
import 'package:sip_ua/sip_ua.dart';

class SipController extends GetxController implements SipUaHelperListener {
  late UserModel currentUser;

  ///-------------Controllers-------------
  final WebRtcController webRtcController = Get.put(WebRtcController());
  final SIPUAHelper sipUaHelper = SIPUAHelper();


  ///-------------State Variables-------------
  final RxBool isBusy = false.obs;
  final RxBool isReceivingCall = false.obs;
  final RxBool isVideoCall = false.obs;
  final RxBool isRegistered = false.obs;
  final RxString transportStatus = ''.obs;


  ///-------------OnCall Variables-------------
  Call? _currentCall;


  ///-------------Constructor-------------
  SipController(UserModel user) {
    currentUser = user;
    init(user);
  }


  ///-------------SIP Connections-------------
  Future<void> init(UserModel user) async {
    log("Init connection with SIP Server was called");
    log("User: ${user.displayName}");
    log("SIP: ${user.privateIdentity}");
    log("Password: ${user.password}");

    try {
      final UaSettings settings = UaSettings()
        ..webSocketUrl = SipConfig.webSocketServerUrl
        ..uri = 'sip:${user.privateIdentity}@${SipConfig.domain}'
        ..authorizationUser = user.privateIdentity
        ..password = user.password
        ..displayName = user.displayName
        ..userAgent = 'SIP-TEST'
        ..transportType = TransportType.WS
        ..webSocketSettings.allowBadCertificate = true
        ..dtmfMode = DtmfMode.RFC2833
        ..realm = "asterisk"
        ..iceServers = [
          {'urls': SipConfig.iceServer}
        ];

      sipUaHelper.addSipUaHelperListener(this);
      await sipUaHelper.start(settings);
    } catch (e) {
      log("Init connection with SIP Server had an error: $e");
    }
  }

  Future<void> initAgain() async {
    await init(currentUser);
  }

  @override
  void onClose() {
    sipUaHelper.removeSipUaHelperListener(this);
    sipUaHelper.stop();
    isRegistered.value = false;
    super.onClose();
  }


  ///-------------Overrides-------------
  @override
  void callStateChanged(Call call, CallState state) {
    log("Call state changed: ${state.state}");
    switch (state.state) {
      case CallStateEnum.CALL_INITIATION:
      case CallStateEnum.CONNECTING:
        isBusy.value = true;
        break;
      case CallStateEnum.PROGRESS:
        break;
      case CallStateEnum.ACCEPTED:
      case CallStateEnum.CONFIRMED:
        _currentCall = call;
        break;
      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        hangUpCall();
        break;
      case CallStateEnum.STREAM:
        webRtcController.setRemoteStream(state.stream);
        break;
      default:
        break;
    }

    if (call.direction == 'INCOMING' &&
        state.state == CallStateEnum.CALL_INITIATION) {
      _currentCall = call;
      isReceivingCall.value = true;
      isVideoCall.value = call.remote_has_video;
    }
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    log("Registration state: ${state.state}");
    isRegistered.value = state.state == RegistrationStateEnum.REGISTERED;
  }

  @override
  void transportStateChanged(TransportState state) {
    log("Transport state: ${state.state}");
    transportStatus.value = state.state.toString();
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    log("new msg: $msg");
  }

  @override
  void onNewNotify(Notify ntf) {
    log("New NOTIFY received.");
  }

  @override
  void onNewReinvite(ReInvite event) {
    log("Reinvite received. Accepting...");
    event.accept?.call(sipUaHelper.buildCallOptions(!event.hasVideo!));
  }


  ///-------------Call Methods-------------
  /// param destination = ramal
  void makeCall(String destination, bool video) async {
    isBusy.value = true;
    isVideoCall.value = video;

    await sipUaHelper.call(
      destination,
      voiceOnly: !video,
      mediaStream: video
          ? webRtcController.localVideo
          : webRtcController.localVoice,
    );
  }

  void hangUpCall() {
    _currentCall?.hangup();
    _currentCall = null;
    isBusy.value = false;
    isReceivingCall.value = false;
    isVideoCall.value = false;
    webRtcController.clearAllStreams();
  }

  void answerCall(bool video) {
    if (_currentCall == null) return;

    final options = sipUaHelper.buildCallOptions(!video);
    _currentCall!.answer(options);

    isReceivingCall.value = false;
    isBusy.value = true;
    isVideoCall.value = video;

  }

}
