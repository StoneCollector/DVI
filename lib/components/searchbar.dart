import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/models/vendor_card.dart';
import 'package:dreamventz/models/venue_models.dart';

enum HomeSearchResultType { category, packageItem, venue, vendor }

class _HomeSearchResult {
  final HomeSearchResultType type;
  final String title;
  final String subtitle;
  final dynamic payload;

  const _HomeSearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.payload,
  });
}

class HomeSearchBar extends StatefulWidget {
  final List<Map<String, dynamic>> serviceCategories;
  final List<Map<String, dynamic>> trendingPackages;
  final Map<String, List<VenueData>> venuesByCategory;
  final List<VendorCard> vendors;
  final bool isLoadingVendors;
  final ValueChanged<Map<String, dynamic>> onCategoryTap;
  final ValueChanged<Map<String, dynamic>> onPackageTap;
  final ValueChanged<VenueData> onVenueTap;
  final ValueChanged<VendorCard> onVendorTap;
  final int maxResults;
  final Duration debounceDuration;
  final double activeBottomSpacing;
  final double idleBottomSpacing;

  const HomeSearchBar({
    super.key,
    required this.serviceCategories,
    required this.trendingPackages,
    required this.venuesByCategory,
    required this.vendors,
    required this.isLoadingVendors,
    required this.onCategoryTap,
    required this.onPackageTap,
    required this.onVenueTap,
    required this.onVendorTap,
    this.maxResults = 4,
    this.debounceDuration = const Duration(milliseconds: 250),
    this.activeBottomSpacing = 14,
    this.idleBottomSpacing = 25,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _debouncedSearchQuery = '';

  bool _containsQuery(String value, String query) {
    return value.toLowerCase().contains(query.toLowerCase());
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _debouncedSearchQuery = '';
      });
      return;
    }

    _searchDebounce = Timer(widget.debounceDuration, () {
      if (!mounted) return;
      setState(() {
        _debouncedSearchQuery = value.trim();
      });
    });
  }

  List<_HomeSearchResult> _buildSearchResults() {
    final query = _debouncedSearchQuery;
    if (query.isEmpty) return [];

    final results = <_HomeSearchResult>[];

    for (final category in widget.serviceCategories) {
      final label = category['label'] as String;
      final categoryName = category['categoryName'] as String;
      if (_containsQuery(label, query) || _containsQuery(categoryName, query)) {
        results.add(
          _HomeSearchResult(
            type: HomeSearchResultType.category,
            title: label,
            subtitle: 'Service category',
            payload: category,
          ),
        );
      }
    }

    for (final package in widget.trendingPackages) {
      final title = (package['title'] ?? '').toString();
      final price = (package['price'] ?? '').toString();
      if (_containsQuery(title, query)) {
        results.add(
          _HomeSearchResult(
            type: HomeSearchResultType.packageItem,
            title: title,
            subtitle: price.isEmpty
                ? 'Trending package'
                : 'Trending package • ₹$price',
            payload: package,
          ),
        );
      }
    }

    final allVenues = widget.venuesByCategory.values.expand((v) => v).toList();
    for (final venue in allVenues) {
      final serviceNames = venue.services.map((s) => s.serviceName).join(' ');
      final searchBlob = [
        venue.name,
        venue.shortLocation,
        venue.locationAddress ?? '',
        venue.category ?? '',
        serviceNames,
      ].join(' ');

      if (_containsQuery(searchBlob, query)) {
        results.add(
          _HomeSearchResult(
            type: HomeSearchResultType.venue,
            title: venue.name,
            subtitle: 'Venue • ${venue.shortLocation}',
            payload: venue,
          ),
        );
      }
    }

    for (final vendor in widget.vendors) {
      final searchBlob = [
        vendor.studioName,
        vendor.city,
        vendor.serviceTags.join(' '),
        vendor.qualityTags.join(' '),
      ].join(' ');

      if (_containsQuery(searchBlob, query)) {
        results.add(
          _HomeSearchResult(
            type: HomeSearchResultType.vendor,
            title: vendor.studioName,
            subtitle: 'Vendor • ${vendor.city}',
            payload: vendor,
          ),
        );
      }
    }

    final cleanedResults = results
        .where((result) => result.title.trim().isNotEmpty)
        .toList();

    return cleanedResults.take(widget.maxResults).toList();
  }

  IconData _iconForResult(HomeSearchResultType type) {
    switch (type) {
      case HomeSearchResultType.category:
        return Icons.category;
      case HomeSearchResultType.packageItem:
        return Icons.card_giftcard;
      case HomeSearchResultType.venue:
        return Icons.location_city;
      case HomeSearchResultType.vendor:
        return Icons.storefront;
    }
  }

  void _handleResultTap(_HomeSearchResult result) {
    FocusScope.of(context).unfocus();

    switch (result.type) {
      case HomeSearchResultType.category:
        widget.onCategoryTap(result.payload as Map<String, dynamic>);
        return;
      case HomeSearchResultType.packageItem:
        widget.onPackageTap(result.payload as Map<String, dynamic>);
        return;
      case HomeSearchResultType.venue:
        widget.onVenueTap(result.payload as VenueData);
        return;
      case HomeSearchResultType.vendor:
        widget.onVendorTap(result.payload as VendorCard);
        return;
    }
  }

  Widget _buildSearchSuggestions() {
    final results = _buildSearchResults();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: results.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_off, color: Colors.grey[500]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.isLoadingVendors
                            ? 'Searching...'
                            : 'No matching services, packages, venues, or vendors',
                        style: GoogleFonts.urbanist(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(results.length, (index) {
                  final result = results[index];
                  final title = result.title.trim();
                  final subtitle = result.subtitle.trim();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _handleResultTap(result),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                _iconForResult(result.type),
                                color: const Color(0xff0c1c2c),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.urbanist(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xff0c1c2c),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.urbanist(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xff0c1c2c),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (index < results.length - 1)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        ),
                    ],
                  );
                }),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasSearchText = _searchController.text.trim().isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 55,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    textInputAction: TextInputAction.search,
                    style: GoogleFonts.urbanist(
                      color: const Color(0xff0c1c2c),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Search packages, services, venues...',
                      hintStyle: GoogleFonts.urbanist(
                        color: Colors.grey[500],
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (hasSearchText)
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      _searchDebounce?.cancel();
                      _searchController.clear();
                      setState(() {
                        _debouncedSearchQuery = '';
                      });
                    },
                    child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                  ),
              ],
            ),
          ),
        ),
        if (hasSearchText) _buildSearchSuggestions(),
        SizedBox(
          height: hasSearchText
              ? widget.activeBottomSpacing
              : widget.idleBottomSpacing,
        ),
      ],
    );
  }
}
