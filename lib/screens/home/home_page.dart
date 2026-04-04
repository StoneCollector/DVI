import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/carousel.dart';
import 'package:dreamventz/components/searchbar.dart';
import 'package:dreamventz/models/vendor_card.dart';
import 'package:dreamventz/screens/vendors/vendor_list_page.dart';
import 'package:dreamventz/screens/vendors/vendor_profile_page.dart';
import 'package:dreamventz/screens/profile/user_profile_page.dart';
import 'package:dreamventz/screens/venues/venue_detail_page.dart';
import 'package:dreamventz/services/vendor_card_service.dart';
import 'package:dreamventz/services/venue_service.dart';
import 'package:dreamventz/models/venue_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamventz/screens/home/widgets/home_header.dart';
import 'package:dreamventz/screens/home/widgets/home_categories_section.dart';
import 'package:dreamventz/screens/home/widgets/promotional_banners.dart';
import 'package:dreamventz/screens/home/widgets/popular_venues_section.dart';
import 'package:dreamventz/screens/home/widgets/trending_packages_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> trendingPackages = [];
  List<VendorCard> allVendorCards = [];
  bool isLoading = true;
  String userName = 'User';
  String? avatarUrl;
  bool isLoadingUser = true;
  bool _showProfilePrompt = false;
  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = true;
  bool isLoadingVendorsForSearch = true;
  static const String _cacheKey = 'trending_packages_cache';
  static const String _cacheTimeKey = 'trending_packages_cache_time';

  // Hardcoded fallback categories for the SearchBar until dynamic categories can be integrated there as well
  static const List<Map<String, dynamic>> _fallbackCategories = [
    {'label': 'Photography', 'categoryName': 'Photography', 'categoryId': 1},
    {'label': 'Catering', 'categoryName': 'Caterers', 'categoryId': 4},
    {'label': 'DJ & Bands', 'categoryName': 'DJ & Bands', 'categoryId': 5},
    {'label': 'Decoraters', 'categoryName': 'Decoraters', 'categoryId': 6},
    {
      'label': 'Mehndi Artist',
      'categoryName': 'Mehndi Artist',
      'categoryId': 2,
    },
  ];

  // Venues data
  Map<String, List<VenueData>> venuesByCategory = {};
  bool isLoadingVenues = true;
  final _venueService = VenueService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadCachedData();
    _fetchCategories();
    _fetchVenues();
    _fetchAllVendorsForSearch();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('full_name, avatar_url, address, pin_code, phone')
            .eq('id', userId)
            .single();

        if (mounted) {
          setState(() {
            userName = response['full_name'] ?? 'User';
            avatarUrl = response['avatar_url'];

            // Check if profile is incomplete
            final address = response['address'] as String?;
            final pinCode = response['pin_code'] as String?;
            final phone = response['phone'] as String?;

            if (address == null ||
                address.isEmpty ||
                pinCode == null ||
                pinCode.isEmpty ||
                phone == null ||
                phone.isEmpty) {
              _showProfilePrompt = true;
            }

            isLoadingUser = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingUser = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      if (mounted) {
        setState(() {
          isLoadingUser = false;
        });
      }
    }
  }

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

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);

      if (cachedData != null) {
        // Load from cache immediately
        final List<dynamic> decoded = jsonDecode(cachedData);
        if (mounted) {
          setState(() {
            trendingPackages = List<Map<String, dynamic>>.from(decoded);
            isLoading = false;
          });
        }
      } else {
        // No cache exists, fetch data
        await _fetchTrendingPackages();
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
      await _fetchTrendingPackages();
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('vendor_categories')
          .select()
          .order('id');

      if (mounted) {
        setState(() {
          categories = List<Map<String, dynamic>>.from(response);
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching vendor categories: $e');
      if (mounted) {
        setState(() {
          isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _fetchTrendingPackages() async {
    try {
      final response = await Supabase.instance.client
          .from('trending_packages')
          .select()
          .order('display_order');

      final packages = List<Map<String, dynamic>>.from(response);

      // Cache the data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(packages));
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

      if (mounted) {
        setState(() {
          trendingPackages = packages;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching trending packages: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    // Haptic feedback for Instagram-style refresh
    HapticFeedback.mediumImpact();

    await Future.wait([
      _fetchTrendingPackages(),
      _fetchCategories(),
      _fetchVenues(),
      _fetchAllVendorsForSearch(),
      Future.delayed(
        const Duration(milliseconds: 500),
      ), // Minimum refresh time for better UX
    ]);

    HapticFeedback.lightImpact();
  }

  Future<void> _fetchVenues() async {
    try {
      final categorizedVenues = await _venueService.getVenuesByCategory();

      if (mounted) {
        setState(() {
          venuesByCategory = categorizedVenues;
          isLoadingVenues = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching venues: $e');
      if (mounted) {
        setState(() {
          isLoadingVenues = false;
        });
      }
    }
  }

  Future<void> _fetchAllVendorsForSearch() async {
    if (mounted) {
      setState(() {
        isLoadingVendorsForSearch = true;
      });
    }

    final vendorService = VendorCardService();

    try {
      var vendors = await vendorService.getAllVendorCards();

      if (vendors.isEmpty) {
        vendors = await _fetchVendorsByKnownCategories(vendorService);
      }

      if (mounted) {
        setState(() {
          allVendorCards = vendors;
          isLoadingVendorsForSearch = false;
        });
      }
    } catch (e) {
      debugPrint(
        'Error fetching all vendors for search, trying category fallback: $e',
      );

      try {
        final fallbackVendors = await _fetchVendorsByKnownCategories(
          vendorService,
        );
        if (mounted) {
          setState(() {
            allVendorCards = fallbackVendors;
            isLoadingVendorsForSearch = false;
          });
        }
      } catch (fallbackError) {
        debugPrint(
          'Error fetching fallback vendors for search: $fallbackError',
        );
        if (mounted) {
          setState(() {
            allVendorCards = [];
            isLoadingVendorsForSearch = false;
          });
        }
      }
    }
  }

  Future<List<VendorCard>> _fetchVendorsByKnownCategories(
    VendorCardService vendorService,
  ) async {
    final categoryIds =
        (categories.isNotEmpty ? categories : _fallbackCategories)
            .map((c) => (c['id'] ?? c['categoryId']) as int)
            .toList();

    final vendorLists = await Future.wait(
      categoryIds.map(vendorService.getVendorCardsByCategory),
    );

    final vendorById = <String, VendorCard>{};
    for (final vendors in vendorLists) {
      for (final vendor in vendors) {
        vendorById[vendor.id] = vendor;
      }
    }

    return vendorById.values.toList();
  }

  void _openVendorSearchResult(VendorCard vendor) {
    final vendorData = {
      'id': vendor.id,
      'studio_name': vendor.studioName,
      'city': vendor.city,
      'image_path': vendor.imagePath,
      'service_tags': vendor.serviceTags,
      'quality_tags': vendor.qualityTags,
      'original_price': vendor.originalPrice,
      'discounted_price': vendor.discountedPrice,
      'rating': 4.5,
      'reviewCount': 0,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorProfilePage(vendorData: vendorData),
      ),
    );
  }

  Widget _buildProfileCompletionPrompt() {
    if (!_showProfilePrompt) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff0c1c2c),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    212,
                    175,
                    55,
                  ).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color.fromARGB(255, 212, 175, 55),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Add your address and contact details for better service.',
                      style: GoogleFonts.urbanist(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _showProfilePrompt = false);
                },
                icon: const Icon(Icons.close, color: Colors.white60, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfilePage(startInEditMode: true),
                  ),
                ).then((_) => _fetchUserProfile());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 212, 175, 55),
                foregroundColor: const Color(0xff0c1c2c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Update Profile Now',
                style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even with short content
          child: Column(
            children: [
              HomeHeader(
                isLoadingUser: isLoadingUser,
                userName: userName,
                avatarUrl: avatarUrl,
              ),
              _buildProfileCompletionPrompt(),
              const SizedBox(height: 10),
              HomeSearchBar(
                serviceCategories: categories.isNotEmpty
                    ? categories
                          .map(
                            (c) => {
                              'label': c['name'],
                              'categoryName': c['name'],
                              'categoryId': c['id'],
                            },
                          )
                          .toList()
                    : _fallbackCategories,
                trendingPackages: trendingPackages,
                venuesByCategory: venuesByCategory,
                vendors: allVendorCards,
                isLoadingVendors: isLoadingVendorsForSearch,
                onCategoryTap: (data) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorListPage(
                        categoryName: data['categoryName'] as String,
                        categoryId: data['categoryId'] as int,
                      ),
                    ),
                  );
                },
                onPackageTap: (_) {
                  Navigator.pushNamed(context, '/bookpackage');
                },
                onVenueTap: (venue) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VenueDetailPage(venue: venue),
                    ),
                  );
                },
                onVendorTap: _openVendorSearchResult,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: const Carousel(),
              ),
              const SizedBox(height: 20),
              HomeCategoriesSection(
                categories: categories,
                isLoading: isLoadingCategories,
              ),
              const SizedBox(height: 20),
              const PromotionalBanners(),
              const SizedBox(height: 15),
              PopularVenuesSection(
                venuesByCategory: venuesByCategory,
                isLoadingVenues: isLoadingVenues,
              ),
              const SizedBox(height: 20),
              TrendingPackagesSection(
                trendingPackages: trendingPackages,
                isLoading: isLoading,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
