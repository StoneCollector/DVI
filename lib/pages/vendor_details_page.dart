import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  List<Map<String, dynamic>> vendors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVendors(); // Trigger Supabase fetch on load
  }

  Future<void> _fetchVendors() async {
    try {
      final data = await Supabase.instance.client
          .from('vendor_cards')
          .select('''
          *,
          vendor_categories (
            name 
          )
        ''')
          .eq('category_id', widget.categoryId);

      setState(() {
        vendors = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching vendors: $e');
      setState(() => isLoading = false);
    }
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff0c1c2c)),
            )
          : vendors.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vendors.length,
              itemBuilder: (context, index) {
                final vendor = vendors[index];

                return VendorTile(
                  // Mapping to your SQL schema columns
                  studioName: vendor['studio_name'] ?? 'Untitled Studio',
                  location: vendor['city'] ?? 'Location not specified',
                  imageFileName: vendor['image_path'] ?? '',

                  // Handles numeric price safely to avoid FormatException
                  startingPrice: vendor['discounted_price']?.toString() ?? '0',

                  serviceType: widget.categoryName,

                  // Handling Postgres text[] arrays
                  serviceTags: List<String>.from(vendor['service_tags'] ?? []),
                  qualityTags: List<String>.from(vendor['quality_tags'] ?? []),

                  // Defaulting ratings as they aren't in the current card schema
                  rating: 4.5,
                  reviewCount: 0,

                  onViewProfile: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VendorProfilePage(vendorData: vendor),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No vendors found in ${widget.categoryName}",
            style: GoogleFonts.urbanist(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
