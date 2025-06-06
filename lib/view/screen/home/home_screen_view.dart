import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/auth_controller.dart';
import 'package:pocsip/controller/call_controller.dart';

import 'package:pocsip/model/ui/register_state_ui_model.dart';
import 'package:pocsip/view/screen/call/call_states/default_call_view.dart';
import 'package:pocsip/view/screen/call/call_states/incoming_call_view.dart';
import 'package:pocsip/view/screen/call/call_states/making_call_view.dart';
import 'package:sip_ua/sip_ua.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {

  final _auth = Get.find<AuthController>();
  final _callController = Get.find<CallController>();

  final TextEditingController _ramalTextController = TextEditingController();

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

            final currentRegisterState = _callController.registrationState.value;
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


        final currentCallState = _callController.callState.value;
        final currentCall = _callController.currentCall;


        if(currentCall == null){
          return const DefaultCallView();  //callStateEnum = none
        } else{

          //TODO CHECK STATES...
          if(currentCallState == CallStateEnum.PROGRESS ||
              currentCallState == CallStateEnum.STREAM ||
              currentCallState == CallStateEnum.CONNECTING ||
              currentCallState == CallStateEnum.CALL_INITIATION){

            if(currentCall.direction == 'INCOMING'){
              return IncomingCallView(currentCall: currentCall);
            } else if(currentCall.direction == 'OUTGOING'){
              return MakingCallView(currentCall.remote_identity);
            } else{
              return const CircularProgressIndicator(); //TODO RETURN ERROR
            }
        }
          else{
            return Center(child: Text("callState: $currentCallState \n currentCall: ${currentCall.direction}"));
          }
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


