import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/call_controller.dart';
import 'package:sip_ua/sip_ua.dart';

class IncomingCallView extends StatelessWidget {
  final Call? currentCall;


  const IncomingCallView({
    super.key,
    required this.currentCall,

  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    final callTypeText = currentCall!.remote_has_video ?
    'Video call from:' : 'Voice call from:';

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.05),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              callTypeText,
              style: TextStyle(
                fontSize: height * 0.03,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.02),
            Text(
              'Ramal: ${currentCall!.remote_identity}',
              style: TextStyle(
                fontSize: height * 0.025,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.04),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAdaptiveButton(
                  context,
                  icon: Icons.call,
                  label: "Voice",
                  color: Colors.purpleAccent,
                  onPressed: () => Get.find<CallController>().acceptCall(withVideo: false),
                ),
                _buildAdaptiveButton(
                  context,
                  icon: Icons.videocam,
                  label: "Video",
                  color: Colors.cyan,
                  onPressed: () => Get.find<CallController>().acceptCall(withVideo: true),
                ),
                _buildAdaptiveButton(
                  context,
                  icon: Icons.call_end,
                  label: "Refuse",
                  color: Colors.red,
                  onPressed: () => Get.find<CallController>().endCall(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptiveButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.01),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: height * 0.03),
          label: Text(
            label,
            style: TextStyle(fontSize: height * 0.02),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: height * 0.02),
            backgroundColor: color,
          ),
        ),
      ),
    );
  }
}