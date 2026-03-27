import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/trending_tile.dart';

class TrendingPackagesSection extends StatefulWidget {
  final List<Map<String, dynamic>> trendingPackages;
  final bool isLoading;

  const TrendingPackagesSection({
    super.key,
    required this.trendingPackages,
    required this.isLoading,
  });

  @override
  State<TrendingPackagesSection> createState() =>
      _TrendingPackagesSectionState();
}

class _TrendingPackagesSectionState extends State<TrendingPackagesSection> {
  final ScrollController _scrollController = ScrollController();
  bool _userInteracted = false;
  Timer? _resumeTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
    }
  }

  @override
  void didUpdateWidget(TrendingPackagesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading && !widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
    }
  }

  void _startAutoScroll() {
    if (widget.trendingPackages.isEmpty ||
        !_scrollController.hasClients ||
        _userInteracted) {
      return;
    }

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

  void _onUserInteractionStart() {
    _userInteracted = true;
    _resumeTimer?.cancel();
  }

  void _onUserInteractionEnd() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 4), () {
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
    return Column(
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
                  color: const Color(0xff0c1c2c),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/packages'),
                child: Row(
                  children: [
                    Text(
                      "See More",
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
          height: 210,
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.trendingPackages.isEmpty
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
                        } else if (notification is ScrollEndNotification) {
                          _onUserInteractionEnd();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        clipBehavior: Clip.none,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                        ),
                        itemCount: widget.trendingPackages.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final package = widget.trendingPackages[index];
                          return TrendingTile(
                            title: package['title'] ?? '',
                            price: package['price'] ?? '',
                            imageFileName: package['image_filename'] ?? '',
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
