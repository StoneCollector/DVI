import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/home_category_tile.dart';
import 'package:dreamventz/screens/vendors/vendor_list_page.dart';

class HomeCategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final bool isLoading;

  const HomeCategoriesSection({
    super.key,
    required this.categories,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Categories",
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xff0c1c2c),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/vendorcategories'),
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
        const SizedBox(height: 15),
        SizedBox(
          height: 135, // Increased to fit larger rounded squares + text
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xff0c1c2c)),
                )
              : categories.isEmpty
                  ? Center(
                      child: Text(
                        'No categories found',
                        style: GoogleFonts.urbanist(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      clipBehavior: Clip.none,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: HomeCategoryTile(
                            name: category['name'] ?? '',
                            imageUrl: category['image_url'] ?? '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VendorListPage(
                                    categoryName: category['name'] ?? '',
                                    categoryId: (category['id'] ?? 0) is int
                                        ? category['id'] as int
                                        : int.tryParse(
                                              '${category['id'] ?? 0}',
                                            ) ??
                                            0,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
