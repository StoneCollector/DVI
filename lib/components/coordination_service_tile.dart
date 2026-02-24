import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/coordination_service_model.dart';

class CoordinationServiceTile extends StatelessWidget {
  final CoordinationService service;
  final VoidCallback onBookNow;

  const CoordinationServiceTile({
    super.key,
    required this.service,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _buildImage(),
              ),
              if (service.hasTag) _buildTagBadge(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff0c1c2c),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  service.description,
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.urbanist(fontSize: 16),
                    children: [
                      const TextSpan(
                        text: "Starting from ",
                        style: TextStyle(
                          color: Color(0xFFD81B60),
                        ),
                      ),
                      TextSpan(
                        text: "₹${service.formattedPrice}",
                        style: const TextStyle(
                          color: Color(0xFFD81B60),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: " / event",
                        style: TextStyle(color: Color(0xFFD81B60)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: onBookNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD81B60),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Book Service",
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (service.imageUrl == null || service.imageUrl!.isEmpty) {
      return _buildPlaceholderImage();
    }

    // All images from Supabase Storage are network images
    return Image.network(
      service.imageUrl!,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 180,
          width: double.infinity,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              color: const Color(0xff0c1c2c),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image load error: $error');
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Service Image',
            style: GoogleFonts.urbanist(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagBadge() {
    final bool isFlagship = service.isFlagship;

    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isFlagship
                ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                : [const Color(0xFF00E676), const Color(0xFF00C853)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFlagship ? Icons.star_border : Icons.fiber_new,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              service.tag!.toUpperCase(),
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
