import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Reusable TextField Widget
Widget inputData(
  TextEditingController ctrl,
  String hint, {
  bool obscure = false,
  bool isValid = true,
  String? errorMessage,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: ctrl,
        obscureText: obscure,
        style: GoogleFonts.tajawal(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.tajawal(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          enabledBorder: _inputBorder(
            isValid ? const Color.fromARGB(100, 7, 7, 7) : Colors.red,
            1.5,
          ),
          focusedBorder: _inputBorder(
            isValid ? const Color.fromARGB(100, 0, 0, 0) : Colors.red,
            2,
          ),
        ),
      ),
      // Always reserve space for error message
      SizedBox(
        height: 20,
        child:
            isValid
                ? const SizedBox.shrink() // empty space, same height
                : Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    errorMessage ?? 'يرجى ملء هذا الحقل',
                    style: GoogleFonts.tajawal(fontSize: 12, color: Colors.red),
                  ),
                ),
      ),
    ],
  );
}

OutlineInputBorder _inputBorder(Color color, double width) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );
}
