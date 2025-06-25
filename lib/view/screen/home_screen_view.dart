import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/auth_controller.dart';
import 'package:pocsip/controller/call_controller.dart';

import 'package:pocsip/model/ui/register_state_ui_model.dart';
import 'package:pocsip/view/states/call/default_call_view.dart';
import 'package:pocsip/view/states/call/incoming_call_view.dart';
import 'package:pocsip/view/states/call/making_call_view.dart';
import 'package:pocsip/view/states/call/on_call_view.dart';
import 'package:sip_ua/sip_ua.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {

  final _auth = Get.find<AuthController>();
  final _callController = Get.find<CallController>();

  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,

        title: const Text('SIP - HOME',
          style: TextStyle(color: Colors.white),),

        actions: [

          Obx(() {

            final currentRegisterState = _callController.currentRegistrationStateEnum.value;
            final isNotRegistered = currentRegisterState != RegistrationStateEnum.REGISTERED;

            final registerStateUi =
            _getRegisterStateUi(currentRegisterState);

            return IconButton(
              icon:  Icon(registerStateUi.icon,
                color: registerStateUi.color,
                shadows: const [
                  Shadow( color: Colors.black,
                    offset: Offset(5, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              tooltip: 'Register',  onPressed: isNotRegistered
                ? () async {
              await _auth.login(currentUser!);
            }
                : null,
            );

          }

          ),

          SizedBox(width: width * 0.065),

          IconButton(
            icon: const Icon(Icons.logout,color: Colors.white),
            tooltip: 'Exit',
            onPressed: () {
              _auth.logout();
              Get.offAllNamed('/login');
            },
          ),

        ],

      ),


      body: Obx(() {
        final currentCallStateEnum = _callController.currentCallStateEnum.value;
        final currentCall          = _callController.currentCall.value;

        if (currentCall == null) {
          return const DefaultCallView();

        } else if (currentCall.direction == 'INCOMING' &&
            currentCallStateEnum == CallStateEnum.PROGRESS) {
          return IncomingCallView(currentCall: currentCall);

        } else if (currentCall.direction == 'OUTGOING' &&
            currentCallStateEnum == CallStateEnum.PROGRESS) {
          return MakingCallView(currentCall.remote_identity);

        } else if (currentCallStateEnum == CallStateEnum.CONFIRMED &&
            (currentCall.direction == 'OUTGOING' ||
                currentCall.direction == 'INCOMING')) {
          return const OnCallView();


        } else if (currentCallStateEnum == CallStateEnum.STREAM &&
            currentCall.direction == 'OUTGOING' &&
            _callController.remoteStream.value != null) {
          return const OnCallView();

        } else {
          return const DefaultCallView();
        }
      }),

    );

  }

  ///Return the current UI registration of Sip server
  RegisterStateUiModel _getRegisterStateUi(RegistrationStateEnum currentRegisterState) {

      if(currentRegisterState != RegistrationStateEnum.REGISTERED) {
        return RegisterStateUiModel(icon: Icons.phone_disabled_outlined, color: Colors.red);
      } else{
        return RegisterStateUiModel(icon: Icons.check_circle, color: Colors.green);
      }

    }

  }

//TODO verify:  can't call because it is locked in a existing call on SIP Side?
