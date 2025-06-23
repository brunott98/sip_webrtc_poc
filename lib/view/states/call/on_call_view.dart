import 'dart:async';
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

  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _localRenderer  = RTCVideoRenderer();

  final Rx<Duration> _elapsed = const Duration().obs;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _startTicker();

    ever<MediaStream?>(_callController.remoteStream, _updateRemoteStream);
    ever<MediaStream?>(_callController.localStream,  _updateLocalStream);
  }

  Future<void> _initRenderers() async {
    await _remoteRenderer.initialize();
    await _localRenderer.initialize();
    _updateRemoteStream(_callController.remoteStream.value);
    _updateLocalStream(_callController.localStream.value);
  }

  void _updateRemoteStream(MediaStream? stream) {
    setState(() => _remoteRenderer.srcObject = stream);
  }

  void _updateLocalStream(MediaStream? stream) {
    setState(() => _localRenderer
      ..srcObject = stream
      ..muted     = true);
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_callController.callState.value == CallStateEnum.CONFIRMED ||
          _callController.callState.value == CallStateEnum.STREAM) {
        _elapsed.value += const Duration(seconds: 1);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _remoteRenderer.dispose();
    _localRenderer.dispose();
    super.dispose();
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
    final isVideo = !call.voiceOnly && call.remote_has_video;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            ///remote
            Positioned.fill(
              child: isVideo
                  ? RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
                  : _buildVoicePlaceholder(theme, ramal),
            ),
            /// local
            if (isVideo)
              Positioned(
                right: 16,
                top:  16,
                width: width * 0.28,
                height: height * 0.20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RTCVideoView(
                    _localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            /// (ramal + cronômetro)
            Positioned(
              top:  24,
              left: 24,
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ramal $ramal',
                      style: theme.textTheme.titleMedium!
                          .copyWith(color: Colors.white)),
                  Text(_formatElapsed(_elapsed.value),
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: Colors.white70)),
                ],
              )),
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
            _circleButton(
              icon: Icons.mic_off,
              tooltip: 'Mute',
              color: Colors.white38,
              onTap: () => _callController.currentCall.value!.mute(true, false),
              size: iconSize,
            ),
            if (isVideo)
              _circleButton(
                icon: Icons.videocam_off,
                tooltip: 'Vídeo off',
                color: Colors.white38,
                onTap: () => _callController.currentCall.value!.mute(false, true),
                size: iconSize,
              ),
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
              icon: Icons.pause,
              tooltip: 'Hold',
              color: Colors.white38,
              onTap: () => _callController.currentCall.value!.hold(),
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

  String _formatElapsed(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
