import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Venue category tile component (no icon version)
/// Similar to ServicesTile but with different color scheme (purple/pink theme)
class VenueCategoryTile extends StatelessWidget {
  final String label;
  final int venueCount;
  final VoidCallback? onTap;

  const VenueCategoryTile({
    super.key,
    required this.label,
    required this.venueCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Purple/pink gradient background for venue tiles
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF3E5F5), // Light purple
              Color(0xFFFFE6F0), // Light pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24), // Squircle shape
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category label
            Text(
              label.trim(),
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: const Color(0xff0c1c2c),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Venue count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$venueCount ${venueCount == 1 ? 'venue' : 'venues'}',
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
