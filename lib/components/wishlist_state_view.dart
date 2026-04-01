import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WishlistStateView extends StatelessWidget {
  final IconData icon;
  final String message;
  final double topSpacing;
  final Color? iconColor;
  final TextAlign textAlign;

  const WishlistStateView({
    super.key,
    required this.icon,
    required this.message,
    this.topSpacing = 120,
    this.iconColor,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: topSpacing),
        Icon(icon, size: 64, color: iconColor ?? Colors.grey[400]),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: textAlign,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
