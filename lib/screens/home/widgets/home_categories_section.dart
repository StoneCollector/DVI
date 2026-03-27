import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/services_tile.dart';
import 'package:dreamventz/screens/vendors/vendor_list_page.dart';

class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 15.0,
            right: 3,
            bottom: 2,
          ),
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
                onTap: () =>
                    Navigator.pushNamed(context, '/vendorcategories'),
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
            children: [
              ServicesTile(
                icon: Icons.camera_alt,
                label: " Photography ",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorListPage(
                        categoryName: 'Photography',
                        categoryId: 1,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              ServicesTile(
                icon: Icons.restaurant,
                label: "  Catering  ",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorListPage(
                        categoryName: 'Caterers',
                        categoryId: 4,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              ServicesTile(
                icon: Icons.music_note,
                label: "   DJ & Bands   ",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorListPage(
                        categoryName: 'DJ & Bands',
                        categoryId: 5,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              ServicesTile(
                icon: Icons.star,
                label: "   Decoraters   ",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorListPage(
                        categoryName: 'Decoraters',
                        categoryId: 6,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              ServicesTile(
                icon: Icons.brush,
                label: "  Mehndi Artist  ",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorListPage(
                        categoryName: 'Mehndi Artist',
                        categoryId: 2,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }
}
