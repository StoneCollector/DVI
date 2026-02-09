import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/vendor_card_service.dart';

class VendorProfilePage extends StatelessWidget {
  final Map<String, dynamic> vendorData;

  const VendorProfilePage({super.key, required this.vendorData});

  @override
  Widget build(BuildContext context) {
    // Get image URL from vendor_card storage bucket
    final String imageUrl = VendorCardService.getImageUrl(vendorData['image_path'] ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff0c1c2c),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          vendorData['studio_name'] ?? 'Vendor Profile',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Vendor Image Section (Updated to handle Supabase Network Images)
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            // 2. Info Header (Soft Pink Background)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color(0xfffff0f3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendorData['studio_name'] ?? 'Vendor Profile',
                    style: GoogleFonts.urbanist(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff0c1c2c),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.pink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vendorData['city'] ?? 'Location not specified',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        // Defaulting to 4.5 if rating is not in the vendor_cards table
                        "${vendorData['rating'] ?? '4.5'} (${vendorData['reviewCount'] ?? '0'} reviews)",
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0c1c2c),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Detailed Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("What we offer"),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        (vendorData['service_tags'] as List<dynamic>? ?? [])
                            .map(
                              (tag) => Chip(
                                label: Text(
                                  tag.toString(),
                                  style: GoogleFonts.urbanist(fontSize: 13),
                                ),
                                backgroundColor: Colors.grey[100],
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const Divider(height: 20),

                  _buildSectionTitle("Service Information"),
                  _buildInfoRow(
                    Icons.place_outlined,
                    "City",
                    vendorData['city'],
                  ),

                  const Divider(height: 20),

                  _buildSectionTitle("Cost & Pricing"),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Original Price",
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "₹ ${vendorData['original_price'] ?? '0'}",
                              style: GoogleFonts.urbanist(
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Discounted Price",
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "₹ ${vendorData['discounted_price'] ?? '0'}",
                              style: GoogleFonts.urbanist(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  _buildSectionTitle("About Us"),
                  const SizedBox(height: 8),
                  Text(
                    "Professional services located in ${vendorData['city'] ?? 'your city'}. We specialize in high-quality event experiences to make your celebration memorable.",
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0c1c2c),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            "Check Availability",
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.urbanist(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xff0c1c2c),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xff0c1c2c)),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Text(value ?? 'N/A', style: GoogleFonts.urbanist(fontSize: 16)),
        ],
      ),
    );
  }
}
