import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookPackageScreen extends StatelessWidget {
  const BookPackageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff0c1c2c),
        title: Text(
          'Package Details',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(
              'Package Booking Coming Soon',
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xff0c1c2c),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Package details and booking will be available here',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
