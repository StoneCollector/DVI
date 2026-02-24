import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/history_tile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
            width: double.infinity,
            decoration: BoxDecoration(color: Color(0xff0c1c2c)),
            child: Text(
              "History",
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              children: [
              HistoryTile(
                title: "Anaya & Rohit Wedding",
                time: "12th Dec 2025 * 7:00 PM",
                status: "Pending",
                statusColor: const Color.fromARGB(255, 255, 154, 59),
                price: "₹50,000",
              ),
              HistoryTile(
                title: "Shanaya Party",
                time: "12th Dec 2025 * 7:00 PM",
                status: "Pending",
                statusColor: const Color.fromARGB(255, 255, 154, 59),
                price: "₹50,000",
              ),
              HistoryTile(
                title: "Arnav's Birthday",
                time: "12th Dec 2025 * 7:00 PM",
                status: "Confirmed",
                statusColor: Colors.green,
                price: "₹50,000",
              ),
              HistoryTile(
                title: "Arnav's Birthday",
                time: "12th Dec 2025 * 7:00 PM",
                status: "Confirmed",
                statusColor: Colors.green,
                price: "₹50,000",
              ),
              HistoryTile(
                title: "CodeBit Hackathon",
                time: "10th Nov 2025 * 10:00 AM",
                status: "Completed",
                statusColor: Colors.lightBlue,
                price: "₹50,000",
              ),
              HistoryTile(
                title: "Corporate Meetup",
                time: "10th Nov 2025 * 10:00 AM",
                status: "Completed",
                statusColor: Colors.lightBlue,
                price: "₹50,000",
              ),
            ],
            ),
          ),
        ],
      ),
    );
  }
}
