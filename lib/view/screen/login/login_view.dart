import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pocsip/controller/auth_controller.dart';
import '../../../model/data/user_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _authController = Get.find<AuthController>();

  final nameController = TextEditingController();
  final ramalController = TextEditingController();
  final passwordController = TextEditingController();
  final isFormValid = false.obs;

  @override
  void initState() {
    super.initState();
    _requestPermissions();

    nameController.addListener(_validateForm);
    ramalController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    nameController.dispose();
    ramalController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP - LOGIN'),
        toolbarHeight: height * 0.08,
      ),
      body: Obx(
            () => Stack(
          children: [
            _buildForm(width, height),
            if (_authController.isConnecting.value! &&
                !_authController.isRegistered.value!)
              Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(double width, double height) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
      child: Column(
        children: [
          SizedBox(height: height * 0.05),
          _buildTextField(nameController, 'Name', height),
          SizedBox(height: height * 0.025),
          _buildTextField(ramalController, 'Ramal', height, keyboard: TextInputType.number),
          SizedBox(height: height * 0.025),
          _buildTextField(passwordController, 'Senha', height, obscure: true),
          SizedBox(height: height * 0.05),
          Obx(
                () => SizedBox(
              width: width * 0.6,
              height: height * 0.06,
              child: ElevatedButton(
                onPressed: isFormValid.value ? _onLoginPressed : null,
                child: Text(
                  'login',
                  style: TextStyle(fontSize: height * 0.022),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      String label,
      double height,
      {TextInputType keyboard = TextInputType.text, bool obscure = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      style: TextStyle(fontSize: height * 0.022),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: height * 0.022),
        border: const OutlineInputBorder(),
      ),
    );
  }

  ///Helpers
  Future<void> _onLoginPressed() async {
    final user = UserModel(
      displayName: nameController.text,
      privateIdentity: ramalController.text,
      password: passwordController.text,
    );

    await _authController.login(user);

    if (_authController.isRegistered.value!) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar('Error', 'failed to login');
    }
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

}
