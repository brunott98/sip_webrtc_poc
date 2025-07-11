import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:pocsip/controller/call_controller.dart';
import 'package:sip_ua/sip_ua.dart';


///Screen on development
class OnCallView extends StatefulWidget {
  const OnCallView({super.key});

  @override
  State<OnCallView> createState() => _OnCallViewState();
}

class _OnCallViewState extends State<OnCallView> {
  final _callController = Get.find<CallController>();


  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  @override
  void dispose() {
    super.dispose();
    _callController.clear();
  }

  Future<void> _initRenderers() async {
    await _callController.ensureRenderers();
  }


  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {

    final theme   = Theme.of(context);
    final size    = MediaQuery.of(context).size;
    final height  = size.height;
    final width   = size.width;
    final call    = _callController.currentCall.value!;
    final ramal   = call.remote_identity ?? '---';
    final isVideo = call.remote_has_video;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            /// REMOTE --------------------------------------------
            Positioned.fill(
              child: isVideo
                  ? Obx(() =>
              _callController.remoteStream.value == null ||
                  _callController.remoteRenderer.value == null
                  ? _blackScreen()
                  : RTCVideoView(
                _callController.remoteRenderer.value!,
                objectFit: RTCVideoViewObjectFit
                    .RTCVideoViewObjectFitCover,
              ),
              )
                  : _buildVoicePlaceholder(theme, ramal),
            ),

            /// LOCAL ---------------------------------------------
            if (isVideo)
              Positioned(
                right: 16,
                top:  16,
                width: width * 0.28,
                height: height * 0.20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Obx(() =>
                  _callController.localStream.value == null ||
                      _callController.localRenderer.value == null
                      ? _blackScreen()
                      : RTCVideoView(
                    _callController.localRenderer.value!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit
                        .RTCVideoViewObjectFitCover,
                  ),
                  ),
                ),
              ),
            ///control bar
            _buildControls(context, isVideo),
          ],
        ),
      ),
    );
  }

  /// Placeholder onlyvoice
  Widget _buildVoicePlaceholder(ThemeData theme, String ramal) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Icon(Icons.person, size: 120, color: theme.primaryColorLight),
      ),
    );
  }

  /// Controls
  Widget _buildControls(BuildContext context, bool isVideo) {
    final h = MediaQuery.of(context).size.height;
    final iconSize = h * 0.04;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: h * 0.04),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          children: [

            if (isVideo)
              _circleButton(
                icon: Icons.flip_camera_ios,
                tooltip: 'Trocar câmera',
                color: Colors.white38,
                onTap: () =>
                    Helper.switchCamera(_callController.localStream.value!.getVideoTracks()[0]),
                size: iconSize,
              ),

            _circleButton(
              icon: Icons.call_end,
              tooltip: 'Encerrar',
              color: Colors.red,
              onTap: () => _callController.endCall(),
              size: iconSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
    required double size,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }

  Widget _blackScreen() => Container(color: Colors.black);

}
