import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CusButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData? icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? iconColor;

  const CusButton({
    super.key,
    required this.onTap,
    this.icon,
    required this.label,
    this.bgColor = const Color(0xFF64CCC5),
    this.textColor = Colors.white,
    this.iconColor = const Color(0xFF176B87),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      onEnd: () {},
      curve: Curves.easeInOut,
      child: icon != null
          ? TextButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 14, color: iconColor),
              label: Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 8,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: bgColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176B87),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              ),
              onPressed: onTap,
              child: Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
    );
  }
}

class GridButton extends StatelessWidget {
  final String label;
  final ImageProvider image;
  final Color color;
  final Widget? target;
  final VoidCallback? onPressed;

  const GridButton({
    super.key,
    required this.label,
    required this.image,
    required this.color,
    this.target,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onPressed ??
          () {
            if (target != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => target!),
              );
            }
          },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: image, height: 60),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.tajawal(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
