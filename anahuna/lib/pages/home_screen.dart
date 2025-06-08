import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anahuna/components/custom_buttons.dart';
import 'package:anahuna/pages/Features/signtotext.dart';
import 'package:anahuna/pages/Features/signtovoicepage.dart';
import 'package:anahuna/pages/Features/ai_chat_screen.dart';
import 'package:anahuna/services/auth.dart';
import 'package:anahuna/components/popup_dialogs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await _authService.getAuthToken();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF053B50),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'مرحباً بك في أنا هنا',
                      style: GoogleFonts.almarai(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                    const SizedBox(width: 31),
                    if (_authService.isAuthenticated)
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () => AppDialog.showLogoutDialog(context),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'اختر طريقة التفاعل المناسبة لك',
                  style: GoogleFonts.tajawal(fontSize: 18, color: const Color(0xFFEEEEEE)),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GridButton(
                              label: 'تحويل الإشارة إلى نص',
                              image: const AssetImage('assets/images/signtotext.png'),
                              color: const Color(0xFF176B87),
                              target: const SignLanguagePage(),
                            ),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: GridButton(
                              label: 'تحويل الإشارة إلى صوت',
                              image: const AssetImage('assets/images/signtovoice.png'),
                              color: const Color(0xFF1B9C96),
                              target: const SignToVoicePage(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(children:[ Expanded(
                        child: GridButton(
                          label: "تحدث مع روبوت",
                          image: const AssetImage('assets/images/robot2.png'),
                          color: const Color(0xFF176B87),
                          onPressed: () {
                            if (!_authService.isAuthenticated) {
                              AppDialog.showNavigationDialog(
                                context,
                                'للتحدث مع الذكاء الاصطناعي، يجب عليك تسجيل الدخول.',
                                const HomeScreen(),
                              );
                              return;
                            }
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LLMPage()));
                          },
                        ),
                      )])
                     
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
