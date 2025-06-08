import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import '../../services/websocket_service.dart';
import 'package:anahuna/components/custom_buttons.dart';
import 'package:google_fonts/google_fonts.dart';

class SignLanguagePage extends StatefulWidget {
  const SignLanguagePage({super.key});

  @override
  State<SignLanguagePage> createState() => _SignLanguagePageState();
}

class _SignLanguagePageState extends State<SignLanguagePage> {
  late WebSocketHandler _handler;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _handler = WebSocketHandler()..initialize();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    _handler.dispose();
    _scrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFF176B87),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'قم بالإشارة للكاميرا وسيتم عرض الترجمة هنا',
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
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(6),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Text(
          msg,
          style: GoogleFonts.tajawal(fontSize: 16, color: Color(0xFF053B50)),
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
                        ? _buildEmptyChatState()
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
                        onTap: h.currentSentence.isNotEmpty ? h.reset : null,
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
              if (h.totalNeeded > 0 && h.isRecordingActive)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    boxShadow: const [
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
