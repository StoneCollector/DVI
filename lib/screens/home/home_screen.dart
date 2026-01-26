import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/bottombar.dart';
import 'package:dreamventz/components/carasol.dart';
import 'package:dreamventz/components/services_tile.dart';
import 'package:dreamventz/components/trending_tile.dart';
import 'package:dreamventz/config/supabase_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final user = SupabaseConfig.currentUser;
      if (user != null) {
        // Try to get full name from user metadata
        final fullName = user.userMetadata?['full_name'] as String?;
        if (fullName != null && fullName.isNotEmpty) {
          setState(() {
            _userName = fullName.split(' ').first; // Get first name only
          });
        } else {
          // Fallback to email username
          final email = user.email ?? '';
          if (email.isNotEmpty) {
            setState(() {
              _userName = email.split('@').first;
            });
          }
        }
      }
    } catch (e) {
      // Keep default 'User' if anything fails
      debugPrint('Error loading user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //topbar
          Container(
            padding: const EdgeInsets.only(
              top: 30,
              left: 20,
              right: 20,
              bottom: 15,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xff0c1c2c)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good Evening, $_userName 👋🏻",
                  style: GoogleFonts.urbanist(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Location"),
                          content: const Text(
                            "Change location feature coming soon!",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 212, 175, 55),
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Mumbai",
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //hero
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Carasol(),
          ),

          //services
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 3, bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Services",
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff0c1c2c),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/bookservice'),
                      child: Row(
                        children: [
                          Text(
                            "Details",
                            style: GoogleFonts.urbanist(
                              color: const Color(0xff0c1c2c),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xff0c1c2c),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 90,
                child: ListView(
                  clipBehavior: Clip.none,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  children: const [
                    ServicesTile(
                      icon: Icons.camera_alt,
                      label: " Photography ",
                    ),
                    SizedBox(width: 10),
                    ServicesTile(
                      icon: Icons.restaurant,
                      label: "     Catering     ",
                    ),
                    SizedBox(width: 10),
                    ServicesTile(
                      icon: Icons.music_note,
                      label: "       Music       ",
                    ),
                    SizedBox(width: 10),
                    ServicesTile(icon: Icons.star, label: "   Decoration   "),
                    SizedBox(width: 10),
                    ServicesTile(
                      icon: Icons.local_shipping,
                      label: "     Logistics     ",
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ],
          ),

          //trending events
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  bottom: 2,
                  right: 3.0,
                  top: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Trending Packages",
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff0c1c2c),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(
                            "See More",
                            style: GoogleFonts.urbanist(
                              color: const Color(0xff0c1c2c),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xff0c1c2c),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 210,
                child: ListView(
                  clipBehavior: Clip.none,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  children: const [
                    TrendingTile(
                      title: "Gold Wedding Package",
                      price: "₹ 5,00,000",
                      imageFileName: "hero1.jpg",
                    ),
                    SizedBox(width: 10),
                    TrendingTile(
                      title: "Executive Conference Setup",
                      price: "₹ 4,30,000",
                      imageFileName: "hero2.jpg",
                    ),
                    SizedBox(width: 10),
                    TrendingTile(
                      title: "Luxury Party Package",
                      price: "₹ 7,50,000",
                      imageFileName: "hero3.jpg",
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Bottombar(),
        ],
      ),
    );
  }
}
