import 'package:anahuna/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anahuna/components//custom_buttons.dart';
import 'package:anahuna/services/auth.dart';
import 'package:anahuna/components/auth_input_fields.dart';
import 'package:anahuna/pages/AuthPages/signup.dart';
import 'package:anahuna/components/popup_dialogs.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;
  bool isEmailValid = true;
  bool isPasswordValid = true;

  final AuthService _authService = AuthService();

  Future<void> _login() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    setState(() {
      isEmailValid = email.isNotEmpty;
      isPasswordValid = pass.isNotEmpty;
    });

    if (!isEmailValid || !isPasswordValid) return;

    setState(() => isLoading = true);

    final response = await _authService.login(email, pass);

    if (response['success']) {
      // ignore: use_build_context_synchronously
      AppDialog.showNavigationDialog(context, response['message'] ?? "تم تسجيل الدخول بنجاح!", HomeScreen());
    } else {
      // ignore: use_build_context_synchronously
      AppDialog.showNavigationDialog(context, response['message'] ?? "خطأ في البريد الكتروني او كلمة السر", Signin());
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF053B50),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 130),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تسجيل الدخول',
                      style: GoogleFonts.almarai(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'مرحباً بعودتك 👋',
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      inputData(
                        emailCtrl,
                        "البريد الإلكتروني",
                        isValid: isEmailValid,
                      ),
                      const SizedBox(height: 20),
                      inputData(
                        passCtrl,
                        "كلمة المرور",
                        obscure: true,
                        isValid: isPasswordValid,
                      ),
                      const SizedBox(height: 40),
                      if (isLoading)
                        const CircularProgressIndicator()
                      else
                        CusButton(
                          onTap: _login,
                          label: "تسجيل الدخول",
                          bgColor: const Color(0xFF64CCC5),
                          textColor: Colors.white,
                          iconColor: const Color(0xFF176B87),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "ليس لديك حساب؟ ",
                            style: GoogleFonts.tajawal(fontSize: 15),
                          ),
                          GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => Signup()),
                                ),
                            child: Text(
                              "إنشاء حساب",
                              style: GoogleFonts.tajawal(
                                fontSize: 15,
                                color: const Color(0xFF176B87),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
