import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:pocsip/controller/call_controller.dart';

class CallView extends StatefulWidget {
  const CallView({super.key});

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {

  final CallController _callController = Get.find();

  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  MediaStream? _remoteStream;
  MediaStream? _localStream;
  bool _isVideoCall = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _remoteRenderer.initialize();
    await _localRenderer.initialize();

    final call = _callController.currentCall;

    _isVideoCall = call != null && !call.voiceOnly && call.remote_has_video;
    _remoteStream = call?.peerConnection?.getRemoteStreams().firstOrNull;
    _localStream = call?.peerConnection?.getLocalStreams().firstOrNull;

    if (_remoteStream != null) {
      _remoteRenderer.srcObject = _remoteStream;
    }

    if (_localStream != null) {
      _localRenderer.srcObject = _localStream;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          Positioned.fill(
            child: _isVideoCall && _remoteStream != null
                ? RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
                : const Center(
              child: Text(
                'Only voice',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),

          if (_isVideoCall && _localStream != null)
            Positioned(
              bottom: 20,
              left: 20,
              width: 120,
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white54),
                ),
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () async {
                  await _callController.endCall();
                  Get.offAllNamed('/home');
                },
                child: Icon(Icons.call_end),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
