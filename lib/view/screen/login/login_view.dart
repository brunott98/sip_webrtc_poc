import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/auth/user_controller.dart';
import '../../../model/user_model.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  final nameController = TextEditingController();
  final ramalController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool isFormValid = false.obs;

  @override
  void initState() {
    super.initState();
    _requestPermissions();

    nameController.addListener(_validateForm);
    ramalController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.camera.request();
  }

  void _validateForm() {
    isFormValid.value = nameController.text.isNotEmpty &&
        ramalController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ACESSO')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: ramalController,
              decoration: const InputDecoration(labelText: 'Ramal'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
              onPressed: isFormValid.value
                  ? () async {
                final user = UserModel(
                  displayName: nameController.text,
                  privateIdentity: ramalController.text,
                  password: passwordController.text,
                );
                await Get.find<UserController>().login(user);
                Get.toNamed('/home');
              }
                  : null,
              child: const Text('Entrar'),
            )),
          ],
        ),
      ),
    );
  }

}


