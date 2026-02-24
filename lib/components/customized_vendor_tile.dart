import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/utils/supabase_config.dart';
import 'package:dreamventz/pages/vendor_profile_page.dart';

class CustomizedVendorTile extends StatelessWidget {
  final Map<String, dynamic> vendor;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomizedVendorTile({
    super.key,
    required this.vendor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
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
              child: Image.network(
                SupabaseConfig.getVendorImageUrl(vendor['image_path'] ?? ''),
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, color: Colors.grey, size: 24),
                  );
                },
              ),
            ),
            SizedBox(width: 10),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor['studio_name'] ?? 'Vendor',
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        vendor['city'] ?? '',
                        style: GoogleFonts.urbanist(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if ((vendor['service_tags'] as List?)?.isNotEmpty ?? false) ...[
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (vendor['service_tags'] as List)
                          .take(2)
                          .map((tag) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.pink[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag.toString(),
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    color: Colors.pink[700],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  if ((vendor['quality_tags'] as List?)?.isNotEmpty ?? false) ...[
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (vendor['quality_tags'] as List)
                          .take(2)
                          .map((tag) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag.toString(),
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    color: Colors.purple[700],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${(vendor['discounted_price'] ?? 0).toString()}',
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Convert vendor map to format for VendorProfilePage
                          final vendorData = {
                            'studio_name': vendor['studio_name'],
                            'city': vendor['city'],
                            'image_path': vendor['image_path'],
                            'service_tags': vendor['service_tags'] ?? [],
                            'quality_tags': vendor['quality_tags'] ?? [],
                            'original_price': vendor['original_price'],
                            'discounted_price': vendor['discounted_price'],
                            'rating': 4.5,
                            'reviewCount': 0,
                          };
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VendorProfilePage(vendorData: vendorData),
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
              Icon(
                Icons.check_circle,
                color: Color(0xff0c1c2c),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
