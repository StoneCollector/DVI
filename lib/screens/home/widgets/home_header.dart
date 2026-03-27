import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/screens/profile/user_profile_page.dart';

class HomeHeader extends StatelessWidget {
  final bool isLoadingUser;
  final String userName;
  final String? avatarUrl;

  const HomeHeader({
    super.key,
    required this.isLoadingUser,
    required this.userName,
    this.avatarUrl,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 50, // Reduced for compact look
        left: 24,
        right: 24,
        bottom: 16,
      ),
      width: double.infinity,
      decoration: BoxDecoration(color: Color(0xff0c1c2c)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Greeting and Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoadingUser
                      ? "Hello 👋🏻"
                      : "${_getGreeting()}, $userName 👋🏻",
                  style: GoogleFonts.urbanist(
                    fontSize: 22, // Reduced for compact look
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Location"),
                          content: Text(
                            "Change location feature coming soon!",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 212, 175, 55),
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Mumbai",
                        style: GoogleFonts.urbanist(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right side - Profile Icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            },
            child: Hero(
              tag: 'profile_avatar',
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff1a2d40),
                  border: Border.all(
                    color: Color.fromARGB(255, 212, 175, 55),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? Image.network(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 212, 175, 55),
                                size: 24,
                              ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 212, 175, 55),
                          size: 24,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
