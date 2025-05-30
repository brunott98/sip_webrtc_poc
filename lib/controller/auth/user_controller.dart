import 'package:get/get.dart';
import 'package:pocsip/controller/sipconnection/sip_controller.dart';
import 'package:pocsip/model/user_model.dart';


class UserController extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  Future <void> login (UserModel user) async {
    currentUser.value = user;
    Get.put(SipController(user));
  }

  //TODO Create another methods like logout, or remember user...

}
