import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/call_controller.dart';

class MakingCallView extends StatelessWidget {
  final String? ramal;

  const MakingCallView(this.ramal, {super.key});

  @override
  Widget build(BuildContext context) {
    final callController = Get.find<CallController>();

    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.05),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: height * 0.07,
                height: height * 0.07,
                child: const CircularProgressIndicator(),
              ),
              SizedBox(height: height * 0.02),
              Text(
                'Calling $ramal...',
                style: TextStyle(
                  fontSize: height * 0.025,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.025),
              SizedBox(
                width: width * 0.6,
                child: ElevatedButton.icon(
                  onPressed: () => callController.endCall(),
                  icon: Icon(Icons.call_end, size: height * 0.03),
                  label: Text(
                    'Give up',
                    style: TextStyle(fontSize: height * 0.022),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.018,
                      horizontal: width * 0.04,
                    ),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(height * 0.015),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
