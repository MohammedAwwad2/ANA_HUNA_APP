import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anahuna/services/auth.dart';
import 'package:anahuna/pages/onboarding_screen.dart';

class AppDialog {
  static void showCustomDialog({
    required BuildContext context,
    required String message,
    Widget? targetRoute,
    List<DialogAction>? actions,
    Color backgroundColor = const Color(0xFF053B50),
    double borderRadius = 10,
    TextStyle? messageStyle,
  }) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          content: Text(
            message,
            style: messageStyle ?? GoogleFonts.tajawal(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          actions: actions?.map((action) => _buildActionButton(
            context,
            action,
            targetRoute,
          )).toList() ?? [
            if (targetRoute != null)
              _buildActionButton(
                context,
                DialogAction(
                  label: "حسناً",
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                targetRoute,
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionButton(
    BuildContext context,
    DialogAction action,
    Widget? targetRoute,
  ) {
    return TextButton(
      onPressed: action.onPressed ?? () {
        if (targetRoute != null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => targetRoute),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.pop(context);
        }
      },
      child: Text(
        action.label,
        style: action.style ?? GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
    );
  }

  static void showLogoutDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      message: 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      actions: [
        DialogAction(
          label: 'إلغاء',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        DialogAction(
          label: 'تأكيد',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
            AuthService().removeAuthToken();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ChoosingScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  static void showNavigationDialog(BuildContext context, String message, Widget target) {
    showCustomDialog(
      context: context,
      message: message,
      targetRoute: target,
    );
  }
}

class DialogAction {
  final String label;
  final TextStyle? style;
  final VoidCallback? onPressed;

  DialogAction({
    required this.label,
    this.style,
    this.onPressed,
  });
}
