import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Carasol extends StatefulWidget {
  const Carasol({super.key});

  @override
  State<Carasol> createState() => _CarasolState();
}

class _CarasolState extends State<Carasol> with SingleTickerProviderStateMixin {
  List<Map<String, String>> carouselData = [
    {
      'image': 'assets/images/hero2.jpg',
      'title': 'Live Concert Experiences',
      'subtitle': 'High-energy stages, sound, lights and crowd management',
    },
    {
      'image': 'assets/images/hero3.jpg',
      'title': 'Tech Events',
      'subtitle': 'Seamless planning for conferences, hackathons and summits',
    },
    {
      'image': 'assets/images/hero4.jpg',
      'title': 'Grand Public Events',
      'subtitle': 'From permits to production, we manage it all',
    },
    {
      'image': 'assets/images/hero5.jpg',
      'title': 'Premium Gatherings',
      'subtitle': 'Elegant setups for launches, networking and celebrations',
    },
    {
      'image': 'assets/images/hero6.jpg',
      'title': 'Luxury Wedding Plannings',
      'subtitle': 'Beautiful moments crafted with precision and care',
    },
    {
      'image': 'assets/images/hero7.jpg',
      'title': 'Professional Conferences',
      'subtitle': 'Perfect venues with complete event infrastructure',
    },
  ];

  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: CarouselSlider(
            items: carouselData
                .map(
                  (item) => Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(110, 145, 141, 141),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            item['image']!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                        // Text Content
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    item['title']!,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['subtitle']!,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.95),
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                  _animationController.reset();
                  _animationController.forward();
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(carouselData.length, (index) {
            bool isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: isActive
                  ? AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          width: 60,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.grey.shade300,
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _animationController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 16,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.grey.shade300,
                      ),
                    ),
            );
          }),
        ),
      ],
    );
  }
}
