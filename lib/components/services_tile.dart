import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const ServicesTile({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(110, 145, 141, 141),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              icon,
              color: Color.fromARGB(255, 212, 175, 55),
              size: 30,
            ),
          ),
          Text(label, style: GoogleFonts.urbanist(fontWeight: FontWeight.w500),),
        ],
      ),
    );
  }
}
