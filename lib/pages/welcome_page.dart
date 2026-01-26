import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/utils/supabase_config.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(height: 200),
                Image.network(
                  SupabaseConfig.getImageUrl('logo.jpg'),
                  height: 150,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error, size: 150),
                ),
                SizedBox(height: 40),
                Text(
                  "Crafting Your Dream Events",
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    color: const Color(0xff0c1c2c),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  " Luxury planning for weddings, corporate, and parties.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(192, 12, 28, 44),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0c1c2c),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 60),
                side: BorderSide(
                  color: Color.fromARGB(255, 212, 175, 55),
                  width: 3,
                ),
              ),
              child: Text(
                "Get Started",
                style: GoogleFonts.urbanist(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
