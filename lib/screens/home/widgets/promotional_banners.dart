import 'package:flutter/material.dart';

class PromotionalBanners extends StatelessWidget {
  const PromotionalBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //customize package banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/customize_package_page');
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset(
                  'lib/images/customize.png',
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        //coordination service banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/coordination_service_page');
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset(
                  'lib/images/coordinate.png',
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
