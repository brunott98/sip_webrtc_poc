import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;



class WebRtcController extends getx.GetxController {

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  MediaStream? _localVideoStream;
  MediaStream? _localVoiceStream;

  MediaStream? get localVideo => _localVideoStream;
  MediaStream? get localVoice => _localVoiceStream;



  Future<void> initializeRenderers({bool withVideo = true}) async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': withVideo
          ? {
        'facingMode': 'user',
        'width': 640,
        'height': 480,
        'frameRate': 30,
      }
          : false,
    };

    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    if (withVideo) {
      _localVideoStream = stream;
      localRenderer.srcObject = _localVideoStream;
    } else {
      _localVoiceStream = stream;
    }
  }


  void setRemoteStream(MediaStream? stream) {
    if (stream != null) {
      remoteRenderer.srcObject = stream;
    }
  }


  void clearAllStreams() {
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    _localVideoStream?.getTracks().forEach((track) => track.stop());
    _localVoiceStream?.getTracks().forEach((track) => track.stop());

    _localVideoStream = null;
    _localVoiceStream = null;
  }

  @override
  void onClose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    clearAllStreams();
    super.onClose();
  }
}
