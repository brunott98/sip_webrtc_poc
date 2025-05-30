import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/auth/user_controller.dart';
import 'package:pocsip/view/screen/login/login_view.dart';
import 'view/screen/call/call_view.dart';
import 'view/screen/home/home_view.dart';

void main() {
  Get.put(UserController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SIP POC',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginView(),
        ),
        GetPage(
          name: '/home',
          page: () => HomeView(),
        ),
        GetPage(
          name: '/call',
          page: () => CallView(),
        ),
      ],
    );
  }
}

