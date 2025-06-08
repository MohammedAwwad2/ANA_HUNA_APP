import 'package:camera/camera.dart';
import 'package:flutter/services.dart';


class CameraService {
  CameraController? _controller;
  Function(List<int>)? onImageProcessed;
  Function(String)? onError;
  bool _isProcessing = false;
  

 
  final int targetWidth = 180;  
  final int targetHeight = 90; 
  final int jpegQuality = 65 ;   

  static const MethodChannel _channel = MethodChannel(
    'com.example.imageProcessor',
  );

  CameraService({
    this.onImageProcessed,
    this.onError,
     
  });

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isProcessing => _isProcessing;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.low,
      imageFormatGroup: ImageFormatGroup.yuv420,
      fps: 15,  
    );

    await _controller!.initialize();

    await _controller!.startImageStream((CameraImage image) { 
      if (_isProcessing) return;
      _processFrame(image);
    });
  }

  void _processFrame(CameraImage image) async {
    if (_isProcessing || onImageProcessed == null) return;

    _isProcessing = true;
      final Map<String, dynamic> imageData = {
        'width': image.width,
        'height': image.height,
        'quality': jpegQuality,
        'planes': image.planes.map((plane) {
          return {
            'bytes': plane.bytes
          };
        }).toList(),
      };

      final Uint8List jpegBytes = await _channel.invokeMethod(
        'convertYUV420ToJpeg',
        imageData,
      );
      onImageProcessed!(jpegBytes);
      _isProcessing = false;
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
