import 'package:get/get.dart';
import 'package:pocsip/controller/call_controller.dart';
import 'package:pocsip/model/data/user_model.dart';
import 'package:pocsip/repository/sip_repository.dart';


class AuthController extends GetxController {

  final SipRepository _sipRepository = Get.put(SipRepository());
  UserModel? currentUser;


  final Rxn<bool> isRegistered = Rxn<bool>(false);  // state: if true, navigate
  final Rxn<bool> isConnecting = Rxn<bool>(false);  // state: if true, start loading animation


  Future<void> login(UserModel user) async {
    isConnecting.value = true;
    isRegistered.value = await _sipRepository.connect(user);
    isConnecting.value = false;
    currentUser = user;
  }


  void logout()  {
    _sipRepository.disconnect();
    currentUser = null;
  }


}
