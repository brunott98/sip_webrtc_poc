import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/sipconnection/sip_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final SipController sipController = Get.find();
  final TextEditingController ramalController = TextEditingController();

  void _showCallTypeDialog(String ramal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Escolher tipo de chamada"),
        content: const Text("Deseja ligar com vídeo ou apenas com voz?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              sipController.webRtcController.initializeRenderers(withVideo: false).then((_) {
                sipController.makeCall(ramal, false);
                Get.toNamed("/call");
              });
            },
            child: const Text("Somente Voz"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              sipController.webRtcController.initializeRenderers(withVideo: true).then((_) {
                sipController.makeCall(ramal, true);
                Get.toNamed("/call");
              });
            },
            child: const Text("Vídeo"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home"),actions: [
        Obx(() {

          return sipController.isRegistered.value
              ? const SizedBox.shrink()
              : IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reativar SIP",
            onPressed: () => sipController.initAgain(),
          );
        }),
        Obx(() {

          return sipController.isRegistered.value
              ? IconButton(
            icon: const Icon(Icons.power_settings_new),
            tooltip: "Desligar SIP",
            onPressed: () => sipController.onClose(),
          )
              : const SizedBox.shrink();
        }),
      ],),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: ramalController,
              decoration: const InputDecoration(labelText: "Digite o ramal"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final ramal = ramalController.text.trim();
                if (ramal.isNotEmpty) {
                  _showCallTypeDialog(ramal);
                }
              },
              icon: const Icon(Icons.call),
              label: const Text("Ligar"),
            ),
            const SizedBox(height: 32),
            Obx(() {
              if (sipController.isReceivingCall.value) {
                return Card(
                  color: Colors.blue.shade50,
                  child: ListTile(
                    title: Text(
                      sipController.isVideoCall.value
                          ? "Chamada de vídeo recebida"
                          : "Chamada de voz recebida",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () {
                            Get.back();
                            sipController.webRtcController.initializeRenderers(
                              withVideo: false,
                            ).then((_) {
                              sipController.answerCall(false);
                              Get.toNamed("/call");
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.videocam),
                          onPressed: () {
                            Get.back();
                            sipController.webRtcController.initializeRenderers(
                              withVideo: true,
                            ).then((_) {
                              sipController.answerCall(true);
                              Get.toNamed("/call");
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
