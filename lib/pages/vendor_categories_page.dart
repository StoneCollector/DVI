import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/vendor_category_tile.dart';
import 'package:dreamventz/pages/vendor_details_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendorCategoriesPage extends StatefulWidget {
  const VendorCategoriesPage({super.key});

  @override
  State<VendorCategoriesPage> createState() => _VendorCategoriesPageState();
}

class _VendorCategoriesPageState extends State<VendorCategoriesPage> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  /// Fetches vendor categories dynamically from Supabase
  Future<void> _fetchCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('vendor_categories')
          .select();

      setState(() {
        categories = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching vendor categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff0c1c2c),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Vendor Categories',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? Center(
              child: Text(
                'No categories available',
                style: GoogleFonts.urbanist(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return VendorCategoryTile(
                    name: category['name'] ?? '',
                    description: category['description'] ?? '',
                    imageUrl: category['image_url'] ?? '',
                    onTap: () {
                      // Navigates to a dynamic page based on the selected category
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorDetailsPage(
                            categoryName: category['name'] ?? '',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
