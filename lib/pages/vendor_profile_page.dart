import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorProfilePage extends StatelessWidget {
  final Map<String, dynamic> vendorData;

  const VendorProfilePage({super.key, required this.vendorData});

  @override
  Widget build(BuildContext context) {
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
          vendorData['studioName'] ?? 'Vendor Profile',
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
            // 1. Vendor Image Section
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: Image.asset(
                'assets/images/${vendorData['imageFileName']}',
                fit: BoxFit.cover,
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
                    vendorData['studioName'] ?? '',
                    style: GoogleFonts.urbanist(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff0c1c2c),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.pink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vendorData['location'] ?? 'Location not specified',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        "${vendorData['rating'] ?? '0.0'} (${vendorData['reviewCount'] ?? '0'} reviews)",
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
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (vendorData['serviceTags'] as List<String>? ?? [])
                        .map(
                          (tag) => Chip(
                            label: Text(
                              tag,
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
                  const Divider(height: 40),

                  _buildSectionTitle("Service Information"),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.category_outlined,
                    "Service Type",
                    vendorData['serviceType'],
                  ),
                  _buildInfoRow(
                    Icons.place_outlined,
                    "City",
                    vendorData['location'],
                  ),

                  const Divider(height: 40),

                  _buildSectionTitle("Cost & Pricing"),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Starting from",
                          style: GoogleFonts.urbanist(fontSize: 16),
                        ),
                        Text(
                          "₹ ${vendorData['startingPrice']}",
                          style: GoogleFonts.urbanist(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  _buildSectionTitle("About Us"),
                  const SizedBox(height: 8),
                  Text(
                    "This is a professional service provider specializing in ${vendorData['serviceType']}. Known for ${vendorData['qualityTags']?.join(', ') ?? 'quality service'}, they ensure your event is memorable and perfectly captured.",
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

      // 4. Sticky Bottom Action Bar
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
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Handle Availability Check
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
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
          ],
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
