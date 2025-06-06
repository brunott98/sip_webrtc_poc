import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/auth_controller.dart';
import 'package:pocsip/view/screen/call/call_screen_view.dart';
import 'package:pocsip/view/screen/login/login_view.dart';
import 'view/screen/home/home_screen_view.dart';


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
          page: () => const LoginView(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreenView(),
        ),
        GetPage(
          name: '/call',
          page: () => const CallView(),
        ),
      ],
    );
  }
}

