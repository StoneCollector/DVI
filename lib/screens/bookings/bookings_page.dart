import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Bookings Page", style: GoogleFonts.urbanist(),),
      ) ,
    );
  }
}
