import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Venue category tile component (no icon version)
/// Similar to ServicesTile but with different color scheme (purple/pink theme)
class VenueCategoryTile extends StatelessWidget {
  final String label;
  final int venueCount;
  final String? imageUrl;
  final VoidCallback? onTap;

  const VenueCategoryTile({
    super.key,
    required this.label,
    required this.venueCount,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: imageUrl != null
              ? DecorationImage(
                  image: AssetImage(imageUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.35),
                    BlendMode.darken,
                  ),
                )
              : null,
          gradient: imageUrl == null
              ? const LinearGradient(
                  colors: [Color(0xFFF3E5F5), Color(0xFFFFE6F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.trim(),
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: imageUrl != null ? Colors.white : const Color(0xff0c1c2c),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
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
