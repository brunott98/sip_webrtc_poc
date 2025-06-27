import 'dart:developer';
import 'package:logger/logger.dart';
import 'package:pocsip/controller/call_controller.dart';
import 'package:pocsip/model/data/user_model.dart';
import 'package:pocsip/util/config/sip_config.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:get/get.dart';

class SipRepository extends GetxController{

  final CallController _callController =
  Get.put(CallController(sipUaHelper: SIPUAHelper(customLogger: Logger(level: Level.off))));

  Future<bool> connect(UserModel user) async {

    try {
      final settings = UaSettings()
        ..webSocketUrl               = SipConfig.webSocketServerUrl
        ..uri                        = 'sip:${user.privateIdentity}@${SipConfig.domain}'
        ..authorizationUser          = user.privateIdentity
        ..password                   = user.password
        ..displayName                = user.displayName
        ..userAgent                  = 'BRUNO-TEST'
        ..transportType              = TransportType.WS
        ..webSocketSettings.allowBadCertificate = true
        ..dtmfMode                   = DtmfMode.RFC2833
        ..realm                      = 'asterisk'
        ..iceServers                 = [{'urls': SipConfig.iceServer}];


      await _callController.currentSipUaHelper!.start(settings);

      if(await _callController.waitForRegistration()){
        _callController.setCurrentRamal(user.privateIdentity);
        return true;
      } else{
        return false;
      }

    } catch (e) {
      log('Init connection with SIP Server had an error: $e');
    }
    return false;
  }


   void disconnect() {
      _callController.disconnect();
  }


}
