import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/models/venue_models.dart';
import 'package:dreamventz/pages/venue_detail_page.dart';

class CustomizedVenueTile extends StatelessWidget {
  final VenueData venue;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomizedVenueTile({
    super.key,
    required this.venue,
    required this.isSelected,
    required this.onTap,
  });

  String formatCurrency(double value) {
    return '₹${value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8, top: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff0c1c2c).withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? Color(0xff0c1c2c) : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: venue.mainImageUrl != null
                  ? Image.network(
                      venue.mainImageUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey, size: 24),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey, size: 24),
                    ),
            ),
            SizedBox(width: 10),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venue Name
                  Text(
                    venue.name,
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3),
                  
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey),
                      SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          venue.shortLocation,
                          style: GoogleFonts.urbanist(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  // Price and View Details Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        formatCurrency(venue.discountedVenuePrice),
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      
                      // View Details Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VenueDetailPage(venue: venue),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'View Details',
                          style: GoogleFonts.urbanist(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
