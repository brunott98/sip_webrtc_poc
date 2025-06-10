import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/auth_controller.dart';
import 'package:pocsip/view/screen/login_screen_view.dart';
import 'view/screen/home_screen_view.dart';


void main() {
  Get.put(AuthController());
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
          page: () => const LoginScreenView(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreenView(),
        ),
      ],
    );
  }
}

