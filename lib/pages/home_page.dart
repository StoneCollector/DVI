import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/carasol.dart';
import 'package:dreamventz/components/services_tile.dart';
import 'package:dreamventz/components/trending_tile.dart';
import 'package:dreamventz/pages/vendor_details_page.dart';
import 'package:dreamventz/pages/user_profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> trendingPackages = [];
  bool isLoading = true;
  String userName = 'User';
  bool isLoadingUser = true;
  static const String _cacheKey = 'trending_packages_cache';
  static const String _cacheTimeKey = 'trending_packages_cache_time';

  // Autoscroll variables
  final ScrollController _scrollController = ScrollController();
  // AnimationController? _scrollAnimation; // field removed
  bool _userInteracted = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadCachedData();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', userId)
            .single();

        setState(() {
          userName = response['full_name'] ?? 'User';
          isLoadingUser = false;
        });
      } else {
        setState(() {
          isLoadingUser = false;
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        isLoadingUser = false;
      });
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
        setState(() {
          trendingPackages = List<Map<String, dynamic>>.from(decoded);
          isLoading = false;
        });
        // Start autoscroll after loading from cache
        WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
      } else {
        // No cache exists, fetch data
        await _fetchTrendingPackages();
      }
    } catch (e) {
      print('Error loading cached data: $e');
      await _fetchTrendingPackages();
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

      setState(() {
        trendingPackages = packages;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching trending packages: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    // Haptic feedback for Instagram-style refresh
    HapticFeedback.mediumImpact();

    await Future.wait([
      _fetchTrendingPackages(),
      Future.delayed(
        Duration(milliseconds: 500),
      ), // Minimum refresh time for better UX
    ]);

    HapticFeedback.lightImpact();
  }

  void _startAutoScroll() {
    if (trendingPackages.isEmpty ||
        !_scrollController.hasClients ||
        _userInteracted)
      return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    // Smooth reset if at end
    if (currentScroll >= maxScroll - 1.0) {
      _scrollController.jumpTo(0);
    }

    final distance = maxScroll - _scrollController.offset;
    if (distance <= 0) return;

    // Speed: ~50 pixels per second
    final duration = Duration(milliseconds: (distance * 20).toInt());

    _scrollController
        .animateTo(maxScroll, duration: duration, curve: Curves.linear)
        .then((_) {
          if (mounted && !_userInteracted) {
            _startAutoScroll();
          }
        });
  }

  Timer? _resumeTimer;

  void _onUserInteractionStart() {
    _userInteracted = true;
    _resumeTimer?.cancel();
    // No need to manually stop animation; user touch does it automatically
  }

  void _onUserInteractionEnd() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(Duration(seconds: 4), () {
      if (mounted) {
        _userInteracted = false;
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    _scrollController.dispose();
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
              AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even with short content
          child: Column(
            children: [
              //topbar
              Container(
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
                          child: Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 212, 175, 55),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Search Bar (One UI Style)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Flat light grey
                    borderRadius: BorderRadius.circular(30), // Pill shape
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600], size: 26),
                      SizedBox(width: 15),
                      Text(
                        "Search packages, services...",
                        style: GoogleFonts.urbanist(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25),

              //hero
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Carasol(),
              ),

              SizedBox(height: 20),

              //services
              Column(
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
                          "Categories", // Renamed to simple 'Categories' for One UI feel
                          style: GoogleFonts.urbanist(
                            fontSize: 24, // Larger
                            fontWeight: FontWeight.w800, // Extra Bold
                            color: Color(0xff0c1c2c),
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
                                  color: Color(0xff0c1c2c),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
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
                      physics: BouncingScrollPhysics(),
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
                                builder: (context) => VendorDetailsPage(
                                  categoryName: 'Photography',
                                  categoryId: 1,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        ServicesTile(
                          icon: Icons.restaurant,
                          label: "Catering",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VendorDetailsPage(
                                  categoryName: 'Catering',
                                  categoryId: 2,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        ServicesTile(
                          icon: Icons.music_note,
                          label: "   DJ & Bands   ",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VendorDetailsPage(
                                  categoryName: 'Music',
                                  categoryId: 3,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        ServicesTile(
                          icon: Icons.star,
                          label: "   Decoraters   ",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VendorDetailsPage(
                                  categoryName: 'Decoration',
                                  categoryId: 4,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        ServicesTile(
                          icon: Icons.brush,
                          label: "  Mehndi Artist  ",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VendorDetailsPage(
                                  categoryName: 'Logistics',
                                  categoryId: 5,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              //trending events
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      bottom: 2,
                      right: 3.0,
                      top: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Trending Packages",
                          style: GoogleFonts.urbanist(
                            fontSize: 24, // Larger
                            fontWeight: FontWeight.w800, // Extra Bold
                            color: Color(0xff0c1c2c),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/packages'),
                          child: Row(
                            children: [
                              Text(
                                "See More",
                                style: GoogleFonts.urbanist(
                                  color: Color(0xff0c1c2c),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
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
                    height: 210,
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : trendingPackages.isEmpty
                        ? Center(
                            child: Text(
                              'No trending packages yet. Add some in Profile!',
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollStartNotification) {
                                _onUserInteractionStart();
                              } else if (notification
                                  is ScrollEndNotification) {
                                _onUserInteractionEnd();
                              }
                              return false;
                            },
                            child: ListView.separated(
                              controller: _scrollController,
                              clipBehavior: Clip.none,
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              itemCount: trendingPackages.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final package = trendingPackages[index];
                                return TrendingTile(
                                  title: package['title'] ?? '',
                                  price: package['price'] ?? '',
                                  imageFileName:
                                      package['image_filename'] ?? '',
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),

              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
