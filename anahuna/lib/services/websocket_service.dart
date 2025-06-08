import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'camera_service.dart';
import 'package:camera/camera.dart';
import 'gemeni_service.dart';

class WebSocketHandler extends ChangeNotifier {
  final String _serverUrl =
      'wss://sign-language-api-514415015721.me-central1.run.app/ws';
  final CameraService _cameraService;
  WebSocketChannel? _channel;

  final List<String> _messages = [];
  String currentSentence = "";
  String newPrediction = "";
  bool isRecording = false;
  int _loadingStatus = 0;
  int _totalNeeded = 30;

  Timer? _predictionDelayTimer;
  final int _predictionDelay = 1300;

  WebSocketHandler()
      : _cameraService = CameraService() {
    _cameraService.onImageProcessed = _sendImageData;
  }

  List<String> get messages => _messages;
  CameraController? get cameraController => _cameraService.controller;
  bool get isInitialized => _cameraService.isInitialized;
  int get loadingStatus => _loadingStatus;
  int get totalNeeded => _totalNeeded;
  bool get isRecordingActive => isRecording;

  Future<void> initialize() async {
    await _cameraService.initialize();
    connect();
    notifyListeners();
  }

  void startRecording() {
    isRecording = true;
    _loadingStatus = 0;
    currentSentence = "";
    newPrediction = "";
    _messages.clear();
    notifyListeners();
  }

  void stopRecording() {
    isRecording = false;
    _loadingStatus = 0;
    notifyListeners();
  }

  void _sendImageData(List<int> imageData) {
    if (_channel == null || !isRecording) return;

    String base64Image = base64Encode(imageData);
    String formattedImage = 'data:image/jpeg;base64,$base64Image';
    
    try {
      _channel?.sink.add(jsonEncode({"image": formattedImage}));
    } catch (e) {
      _handleError('خطأ في إرسال البيانات');
    }
  }

  void _handleMessage(Map<String, dynamic> response) {
    if (!isRecording) return;

    try {
      switch (response['status']) {
        case 'prediction':
          _loadingStatus = response['buffer_level'] ?? 0;
          _totalNeeded = 30;
          
          if (response['prediction'] != null && 
              (response['confidence'] ?? 0.0) > 0.5) {
            _handlePrediction(response['prediction'].toString());
          }
          notifyListeners();
          break;
        case 'error':
          _handleError('خطأ في التعرف على الإشارة');
          break;
      }
    } catch (e) {
      _handleError('خطأ في معالجة البيانات');
    }
  }

  void _handlePrediction(String prediction) {
    if (!isRecording) return;
    
    _predictionDelayTimer?.cancel();
    _predictionDelayTimer = Timer(
      Duration(milliseconds: _predictionDelay),
      () {
        newPrediction = prediction;
       
          currentSentence = '$currentSentence $newPrediction'.trim();
        
        notifyListeners();
      },
    );
  }

  void droplast() {
    if (currentSentence.isEmpty) return;
    
    List<String> words = currentSentence.trim().split(' ');
    if (words.isNotEmpty) {
      words.removeLast();
      currentSentence = words.join(' ').trim();
      newPrediction = "";
      _predictionDelayTimer?.cancel();
      notifyListeners();
    }
  }

  void _handleError(String errorMessage) {
    if (!_messages.contains(errorMessage)) {
      _addMessage(errorMessage);
    }
  }

  void _addMessage(String message) {
    if (message.isNotEmpty) {
      _messages.add(message);
      notifyListeners();
    }
  }

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      _channel!.stream.listen(
        (message) {
          try {
            final decoded = jsonDecode(message);
            _handleMessage(decoded);
          } catch (e) {
            _handleError('خطأ في قراءة البيانات');
          }
        },
        onError: (error) {
          _handleConnectionIssue('خطأ في الاتصال');
        },
        onDone: () {
          _handleConnectionIssue('تم غلق الاتصال');
        },
      );
    } catch (e) {
      _handleConnectionIssue('فشل الاتصال');
    }
  }

  void _handleConnectionIssue(String errorMessage) {
    _handleError(errorMessage);
    _reconnect();
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!isRecording) return;
      connect();
    });
  }

  @override
  void dispose() {
    isRecording = false;
    _predictionDelayTimer?.cancel();
    _cameraService.dispose();
    _channel?.sink.close();
    _channel = null;
    super.dispose();
  }

  Future<void> llm() async {
    _predictionDelayTimer?.cancel();
    final prompt = currentSentence.trim();
    if (prompt.isEmpty) return;

    _addMessage("⌛ جاري الإرسال إلى سؤال");

    try {
      final corrected = await GeminiService().generateText(prompt);
      final answer = await GeminiService().generateText(corrected, isCorrection: false);
      final response = await GeminiService().generateText(answer, isCorrection: false, withAnswer: true);
      _messages.removeLast();
      _addMessage("روبوت: $response");
    } catch (e) {
      _messages.removeLast();
      _addMessage("خطأ في معالجة السؤال");
    }

    currentSentence = "";
    newPrediction = "";
    _loadingStatus = 0;
    notifyListeners();
  }

  Future<void> reset() async {
    if (!isRecording) return;
    
    _predictionDelayTimer?.cancel();
    if (currentSentence.trim().isNotEmpty) {
      try {
        final correctedText = await GeminiService().generateText(currentSentence.trim());
        _addMessage(correctedText);
      } catch (e) {
        _addMessage(currentSentence.trim());
      }
      currentSentence = "";
      newPrediction = "";
    }
    _loadingStatus = 0;
    notifyListeners();
  }
}
