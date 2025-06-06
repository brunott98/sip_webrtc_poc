import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/call_controller.dart';

class DefaultCallView extends StatefulWidget {
  const DefaultCallView({super.key});

  @override
  State<DefaultCallView> createState() => _DefaultCallViewState();
}

class _DefaultCallViewState extends State<DefaultCallView> {
  final _callController = Get.find<CallController>();
  final TextEditingController _ramalTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    final double paddingHorizontal = width * 0.1;
    final double paddingVertical = height * 0.1;
    final double spacing = height * 0.02;
    final double fontSize = height * 0.02;
    final double iconSize = height * 0.03;
    final double buttonHeight = height * 0.07;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _ramalTextController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: fontSize),
            decoration: InputDecoration(
              labelText: 'Ramal',
              labelStyle: TextStyle(fontSize: fontSize),
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                vertical: height * 0.02,
                horizontal: width * 0.03,
              ),
            ),
          ),
          SizedBox(height: spacing),
          SizedBox(
            height: buttonHeight,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                    if(_ramalTextController.text.isNotEmpty){
                      _callController.startCall(
                        ramalTarget: _ramalTextController.text,
                        withVideo: false,
                      );
                    }
                    },
                    icon: Icon(Icons.call, size: iconSize),
                    label: Text("Voice call", style: TextStyle(fontSize: fontSize)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: EdgeInsets.symmetric(vertical: spacing / 2),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if(_ramalTextController.text.isNotEmpty){
                        _callController.startCall(
                          ramalTarget: _ramalTextController.text,
                          withVideo: true,
                        );
                      }
                    },
                    icon: Icon(Icons.videocam, size: iconSize),
                    label: Text("Video call", style: TextStyle(fontSize: fontSize)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: EdgeInsets.symmetric(vertical: spacing / 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
