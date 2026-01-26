import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const ServicesTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFFFF8E1), // Soft pastel amber/gold background
          borderRadius: BorderRadius.circular(24), // Squircle shape
          // Removed shadow for flatter One UI look, or use very subtle one
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFFD4AF37), size: 32),
            SizedBox(height: 8),
            Text(
              label.trim(), // Trim extra spaces
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xff0c1c2c),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
