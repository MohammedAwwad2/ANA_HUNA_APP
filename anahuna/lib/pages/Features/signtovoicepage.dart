import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/websocket_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:anahuna/components/custom_buttons.dart';
import 'package:google_fonts/google_fonts.dart';

class SignToVoicePage extends StatefulWidget {
  const SignToVoicePage({super.key});

  @override
  SignToVoicePageState createState() => SignToVoicePageState();
}

class SignToVoicePageState extends State<SignToVoicePage> {
  late WebSocketHandler _handler;
  final FlutterTts _flutterTts = FlutterTts();
  final ScrollController _scrollController = ScrollController();
  bool _isSpeaking = false;
  String _lastSpokenMessage = '';

  @override
  void initState() {
    super.initState();
    _handler = WebSocketHandler()..initialize();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _configureTts();
  }

  void _configureTts() {
    _flutterTts
      ..setLanguage('ar-SA')
      ..setSpeechRate(0.5)
      ..setVolume(1.0)
      ..setPitch(1.0)
      ..setStartHandler(() => setState(() => _isSpeaking = true))
      ..setCompletionHandler(() => setState(() => _isSpeaking = false))
      ..setErrorHandler((_) => setState(() => _isSpeaking = false));
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    if (_isSpeaking) await _flutterTts.stop();
    await _flutterTts.speak(text);
    setState(() => _lastSpokenMessage = text);
  }

  @override
  void dispose() {
    _handler.dispose();
    _flutterTts.stop();
    _scrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFF176B87),
            child: const Icon(Icons.volume_up, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'قم بالإشارة للكاميرا وسيتم نطق النتائج',
              textAlign: TextAlign.center,
              style: GoogleFonts.almarai(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String msg) {
    final bgColor = const Color(0xFFEEEEEE);
    final textColor = const Color(0xFF053B50);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .7,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomRight: const Radius.circular(6),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isSpeaking && msg == _lastSpokenMessage
                  ? Icons.volume_up
                  : Icons.volume_up_outlined,
              size: 15,
              color: textColor,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                msg,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  color: Color(0xFF053B50),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: Icon(Icons.replay, size: 15, color: textColor),
              onPressed: () => _speak(msg),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
        border: Border(right: BorderSide(color: Colors.black12)),
      ),
      child: Consumer<WebSocketHandler>(
        builder: (_, h, __) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          final msgs = h.messages;

          return Column(
            children: [
              Expanded(
                child:
                    msgs.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          itemCount: msgs.length,
                          itemBuilder: (_, i) => _buildMessageBubble(msgs[i]),
                        ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CusButton(
                        onTap: () {
                          if (h.isRecordingActive) {
                            h.stopRecording();
                          } else {
                            h.startRecording();
                          }
                        },
                        icon: h.isRecordingActive ? Icons.stop_circle : Icons.play_circle,
                        label: h.isRecordingActive ? 'توقف' : 'ابدأ',
                        bgColor: h.isRecordingActive ? Colors.red.shade400 : const Color(0xFF64CCC5),
                        textColor: Colors.white,
                        iconColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CusButton(
                        onTap: h.currentSentence.isNotEmpty ? () async {
                          await h.reset();
                          if (h.messages.isNotEmpty) {
                            _speak(h.messages.last);
                          }
                        } : null,
                        icon: Icons.check_circle,
                        label: 'انهاء',
                        bgColor: h.currentSentence.isNotEmpty 
                            ? const Color(0xFF64CCC5)
                            : Colors.grey.shade400,
                        textColor: Colors.white,
                        iconColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                   
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: CusButton(
                        onTap: h.currentSentence.isNotEmpty ? h.droplast : null,
                        icon: Icons.backspace_outlined,
                        label: "حذف الكلمة الأخيرة",
                        bgColor: h.currentSentence.isNotEmpty 
                            ? const Color(0xFF64CCC5)
                            : Colors.grey.shade400,
                        textColor: Colors.white,
                        iconColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (h.totalNeeded > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      minHeight: 12,
                      value: h.loadingStatus / h.totalNeeded,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF176B87),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Consumer<WebSocketHandler>(
      builder: (_, h, __) {
        return Stack(
          children: [
            Positioned.fill(
              child:
                  h.cameraController != null
                      ? CameraPreview(h.cameraController!)
                      : Container(color: Colors.black),
            ),

            // رجوع button in the top-left using IconTextButton
            Positioned(
              top: 16,
              left: 16,
              child: CusButton(
                onTap: () => Navigator.of(context).pop(),
                icon: Icons.arrow_forward_outlined,
                label: 'رجوع',
                bgColor: const Color(0xFF64CCC5),
                textColor: Colors.white,
                iconColor: const Color(0xFF176B87),
              ),
            ),

            if (h.newPrediction.isNotEmpty)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: const Color(0xFF176B87).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    h.newPrediction,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _handler,
      child: Builder(
        builder: (context) {
          final h = context.watch<WebSocketHandler>();

          if (!h.isInitialized) {
            return const Scaffold(
              backgroundColor: Color(0xFF053B50),
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFF053B50),
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  Expanded(flex: 5, child: _buildChatArea()),
                  Expanded(flex: 6, child: _buildCameraPreview()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
