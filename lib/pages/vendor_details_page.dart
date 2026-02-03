import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/vendor_tile.dart';
import 'package:dreamventz/pages/vendor_profile_page.dart';

class VendorDetailsPage extends StatefulWidget {
  final String categoryName;
  final int categoryId;
  const VendorDetailsPage({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<VendorDetailsPage> createState() => _VendorDetailsPageState();
}

class _VendorDetailsPageState extends State<VendorDetailsPage> {
  List<Map<String, dynamic>> filteredVendors = [];
  String sortBy = 'Rating';
  String selectedCity = 'All';

  @override
  void initState() {
    super.initState();
    _loadCategorySpecificData();
  }

  void _loadCategorySpecificData() {
    // Logic to provide unique 3+ cards per category
    switch (widget.categoryName) {
      case 'Photography':
        filteredVendors = [
          {
            'studioName': 'Raj Photo Studio',
            'serviceType': 'Wedding Photography',
            'rating': 4.8,
            'reviewCount': 320,
            'startingPrice': '25,000',
            'imageFileName': 'hero7.jpg',
            'location': 'Mumbai',
            'serviceTags': ['Wedding', 'Editing'],
            'qualityTags': ['Quality Service'],
          },
          {
            'studioName': 'Creative Frame',
            'serviceType': 'Candid Shots',
            'rating': 4.9,
            'reviewCount': 215,
            'startingPrice': '18,000',
            'imageFileName': 'hero2.jpg',
            'location': 'Delhi',
            'serviceTags': ['Pre-wedding'],
            'qualityTags': ['Customizable'],
          },
          {
            'studioName': 'SnapSutra',
            'serviceType': 'Cinematic',
            'rating': 4.7,
            'reviewCount': 180,
            'startingPrice': '30,000',
            'imageFileName': 'hero3.jpg',
            'location': 'Bangalore',
            'serviceTags': ['Candid'],
            'qualityTags': ['Experienced'],
          },
        ];
        break;
      case 'Catering':
        filteredVendors = [
          {
            'studioName': 'Royal Feast',
            'serviceType': 'North Indian',
            'rating': 4.6,
            'reviewCount': 450,
            'startingPrice': '800',
            'imageFileName': 'catering1.jpg',
            'location': 'Mumbai',
            'budget': 800,
            'serviceTags': ['Buffet', 'Live'],
            'qualityTags': ['Hygienic'],
          },
          {
            'studioName': 'Gourmet Bites',
            'serviceType': 'Continental',
            'rating': 4.8,
            'reviewCount': 120,
            'startingPrice': '1200',
            'imageFileName': 'catering2.jpg',
            'location': 'Navi Mumbai',
            'budget': 700,
            'serviceTags': ['Fine Dine'],
            'qualityTags': ['Premium'],
          },
          {
            'studioName': 'Desi Tadka',
            'serviceType': 'Traditional',
            'rating': 4.3,
            'reviewCount': 890,
            'startingPrice': '500',
            'imageFileName': 'catering3.jpg',
            'location': 'Panvel',
            'budget': 800,
            'serviceTags': ['Outdoor'],
            'qualityTags': ['Affordable'],
          },
        ];
        break;
      default:
        // Default placeholder for other categories
        filteredVendors = List.generate(
          3,
          (index) => {
            'studioName': '${widget.categoryName} Specialist ${index + 1}',
            'serviceType': 'Professional ${widget.categoryName}',
            'rating': 4.5,
            'reviewCount': 50,
            'startingPrice': '15,000',
            'imageFileName': 'hero1.jpg',
            'location': 'Local',
            'budget': 800,
            'serviceTags': ['Professional'],
            'qualityTags': ['Reliable'],
          },
        );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xff0c1c2c),
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: filteredVendors.length,
        itemBuilder: (context, index) {
          final vendor = filteredVendors[index];

          // Create a safe display string
          // If priceLabel exists, combine them; otherwise just show startingPrice
          String displayPrice = vendor['startingPrice'].toString();
          if (vendor.containsKey('priceLabel')) {
            displayPrice = "${vendor['startingPrice']}${vendor['priceLabel']}";
          }

          return VendorTile(
            studioName: vendor['studioName'] ?? '',
            serviceType: vendor['serviceType'] ?? '',
            rating: (vendor['rating'] ?? 0.0).toDouble(),
            reviewCount: vendor['reviewCount'] ?? 0,
            startingPrice:
                displayPrice, // Use the displayPrice that includes the priceLabel if it exists
            imageFileName: vendor['imageFileName'] ?? '',
            location: vendor['location'] ?? '',
            serviceTags: List<String>.from(vendor['serviceTags'] ?? []),
            qualityTags: List<String>.from(vendor['qualityTags'] ?? []),
            onViewProfile: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VendorProfilePage(vendorData: vendor),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
