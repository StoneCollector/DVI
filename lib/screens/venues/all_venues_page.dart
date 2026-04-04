import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/venue_models.dart';
import '../../components/venue_category_tile.dart';
import 'venue_category_list_page.dart';

/// All Venues Page - Shows all venue categories in a grid
class AllVenuesPage extends StatelessWidget {
  final Map<String, List<VenueData>> venuesByCategory;

  const AllVenuesPage({super.key, required this.venuesByCategory});

  // All predefined categories
  static const List<String> allCategories = [
    'Wedding Venue',
    'Corporate Event Space',
    'Party Hall',
    'Celebration Venue',
    'Outdoor Venue',
    'Banquet Hall',
    'Conference Center',
    'Other',
  ];

  static const Map<String, String> _categoryImages = {
    'Wedding Venue': 'assets/images/categories/venue/celebration venue.png',
    'Corporate Event Space': 'assets/images/categories/venue/corporate event space.jpg',
    'Party Hall': 'assets/images/categories/venue/Party Hall.jpg',
    'Celebration Venue': 'assets/images/categories/venue/celebration venue.png',
    'Outdoor Venue': 'assets/images/categories/venue/outdoor venue.jpg',
    'Banquet Hall': 'assets/images/categories/venue/banquet hall.jpg',
    'Conference Center': 'assets/images/categories/venue/conference center.jpg',
    'Other': 'assets/images/categories/venue/other.jpg',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xff0c1c2c),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'All Venue Categories',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final venues = venuesByCategory[category] ?? [];

          return VenueCategoryTile(
            label: category,
            venueCount: venues.length,
            imageUrl: _categoryImages[category],
            onTap: () {
              if (venues.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VenueCategoryListPage(
                      categoryName: category,
                      venues: venues,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'No venues in $category yet',
                      style: GoogleFonts.urbanist(),
                    ),
                    backgroundColor: const Color(0xFF9C27B0),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
