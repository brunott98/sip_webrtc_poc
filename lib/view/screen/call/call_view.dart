import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/sipconnection/sip_controller.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallView extends StatelessWidget {
  const CallView({super.key});

  @override
  Widget build(BuildContext context) {
    final SipController sipController = Get.find();
    final webRtc = sipController.webRtcController;

    return Scaffold(
      appBar: AppBar(title: const Text("Em chamada")),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(webRtc.remoteRenderer),
          ),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.videocam_off),
                  label: const Text("Desligar vídeo"),
                  onPressed: () {
                    webRtc.localVideo?.getVideoTracks().forEach((track) {
                      track.enabled = false;
                    });
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic_off),
                  label: const Text("Desligar áudio"),
                  onPressed: () {
                    webRtc.localVideo?.getAudioTracks().forEach((track) {
                      track.enabled = false;
                    });
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.call_end),
                  label: const Text("Encerrar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    sipController.hangUpCall();
                    Get.offAllNamed("/home");
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: RTCVideoView(webRtc.localRenderer, mirror: true),
          ),
        ],
      ),
    );
  }
}
