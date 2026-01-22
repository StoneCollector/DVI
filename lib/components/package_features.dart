import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PackageFeatures extends StatelessWidget {
  final String value;
  const PackageFeatures({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.check, color: Color.fromARGB(255, 170, 140, 43)),
        Text(
          value,
          style: GoogleFonts.urbanist(fontSize: 16, color: Color(0xff0c1c2c)),
        ),
      ],
    );
  }
}
