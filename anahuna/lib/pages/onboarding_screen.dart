import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anahuna/pages/home_screen.dart';
import 'package:anahuna/pages/AuthPages/signin.dart';
import 'package:anahuna/components/custom_buttons.dart';

class ChoosingScreen extends StatelessWidget {
  const ChoosingScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF053B50),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                Text(
                  'أهلاً بك في عالم التواصل بدون معوقات',
                  style: GoogleFonts.almarai(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEEEEEE),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'تعزيز التفاهم والتواصل بين الصم والعالم من خلال إزالة الحواجز عن طريق تحويل الرموز إلى نصوص أو صوت.',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    color: const Color(0xFFEEEEEE),
                    height: 1.6,
                  ),
                ),

                const Spacer(flex: 5),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CusButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Signin(),
                            ),
                          );
                        },
                        label: 'تسجيل الدخول',
                        bgColor: const Color(0xFF176B87),
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: CusButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                        label: 'تخطي',
                        bgColor: const Color(0xFF176B87),
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
