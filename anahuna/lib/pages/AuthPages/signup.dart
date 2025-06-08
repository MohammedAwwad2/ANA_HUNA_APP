import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anahuna/components/custom_buttons.dart';
import 'package:anahuna/services/auth.dart';
import 'package:anahuna/components/auth_input_fields.dart';
import 'package:anahuna/components/popup_dialogs.dart';
import 'package:anahuna/pages/home_screen.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool isLoading = false;
  bool isFirstNameValid = true;
  bool isLastNameValid = true;
  bool isEmailValid = true;
  bool isPasswordValid = true;
  bool isConfirmValid = true;

  final AuthService _authService = AuthService();

  Future<void> _signup() async {
    final firstName = firstNameCtrl.text.trim();
    final lastName = lastNameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    setState(() {
      isFirstNameValid = firstName.isNotEmpty;
      isLastNameValid = lastName.isNotEmpty;
      isEmailValid = email.isNotEmpty;
      isPasswordValid = pass.isNotEmpty;
      isConfirmValid = confirm.isNotEmpty;
    });

    if (!isFirstNameValid ||
        !isLastNameValid ||
        !isEmailValid ||
        !isPasswordValid ||
        !isConfirmValid) {
      return;
    }

    if (pass != confirm) {
      setState(() {
        isConfirmValid = false;
      });
      return;
    }

    setState(() => isLoading = true);

    final response = await _authService.register(
      email,
      pass,
      firstName: firstName,
      lastName: lastName,
    );

    if (response['success']) {
      // ignore: use_build_context_synchronously
      AppDialog.showNavigationDialog(context, response['message'] ?? "تم إنشاء الحساب بنجاح!", HomeScreen());
    } else {
      // ignore: use_build_context_synchronously
      AppDialog.showNavigationDialog(context, response['message'] ?? "فشل إنشاء الحساب", Signup());
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
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إنشاء حساب',
                      style: GoogleFonts.almarai(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'مرحباً بك 👋',
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: inputData(
                              firstNameCtrl,
                              "الاسم الأول",
                              isValid: isFirstNameValid,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: inputData(
                              lastNameCtrl,
                              "اسم العائلة",
                              isValid: isLastNameValid,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      inputData(
                        emailCtrl,
                        "البريد الإلكتروني",
                        isValid: isEmailValid,
                      ),
                      const SizedBox(height: 10),
                      inputData(
                        passCtrl,
                        "كلمة المرور",
                        obscure: true,
                        isValid: isPasswordValid,
                      ),
                      const SizedBox(height: 10),
                      inputData(
                        confirmCtrl,
                        "تأكيد كلمة المرور",
                        obscure: true,
                        isValid: isConfirmValid,
                        errorMessage: !isConfirmValid && passCtrl.text != confirmCtrl.text 
                            ? "كلمة السر غير متطابقة" 
                            : null,
                      ),
                      const SizedBox(height: 20),
                      if (isLoading)
                        const CircularProgressIndicator()
                      else
                        CusButton(
                          onTap: _signup,
                          label: "إنشاء حساب",
                          bgColor: const Color(0xFF64CCC5),
                          textColor: Colors.white,
                          iconColor: const Color(0xFF176B87),
                        ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "هل لديك حساب؟ ",
                            style: GoogleFonts.tajawal(fontSize: 15),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              "تسجيل الدخول",
                              style: GoogleFonts.tajawal(
                                fontSize: 15,
                                color: const Color(0xFF176B87),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
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
