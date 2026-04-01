import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/sort.dart';
import 'package:dreamventz/services/wishlist_service.dart';
import '../../models/venue_models.dart';
import 'venue_detail_page.dart';

/// Venue Category List Page with Filters - Similar to PhotographyPage
class VenueCategoryListPage extends StatefulWidget {
  final String categoryName;
  final List<VenueData> venues;

  const VenueCategoryListPage({
    super.key,
    required this.categoryName,
    required this.venues,
  });

  @override
  State<VenueCategoryListPage> createState() => _VenueCategoryListPageState();
}

class _VenueCategoryListPageState extends State<VenueCategoryListPage> {
  static const double _budgetStep = 5000;

  List<VenueData> filteredVenues = [];

  // Filter states
  String sortBy = 'Price: Low to High';
  String selectedCity = 'All';
  double selectedMinBudget = 0;
  double selectedMaxBudget = 0;
  double categoryMaxBudget = 0;
  bool hasBudgetData = false;
  final WishlistService _wishlistService = WishlistService();
  Set<String> wishlistedVenueIds = <String>{};
  Set<String> wishlistBusyVenueIds = <String>{};

  bool get _isBudgetFilterActive {
    return hasBudgetData &&
        (selectedMinBudget > 0 || selectedMaxBudget < categoryMaxBudget);
  }

  double _normalizeMaxBudget(double maxPrice) {
    if (maxPrice <= 0) return _budgetStep;
    return (maxPrice / _budgetStep).ceil() * _budgetStep;
  }

  @override
  void initState() {
    super.initState();
    final rawMaxPrice = widget.venues.isEmpty
        ? 0.0
        : widget.venues
              .map((venue) => venue.discountedVenuePrice)
              .reduce((a, b) => a > b ? a : b);

    categoryMaxBudget = _normalizeMaxBudget(rawMaxPrice);
    hasBudgetData = rawMaxPrice > 0;
    selectedMinBudget = 0;
    selectedMaxBudget = categoryMaxBudget;

    filteredVenues = List.from(widget.venues);
    _applyFilters();
    _loadWishlistedVenueIds();
  }

  Future<void> _loadWishlistedVenueIds() async {
    try {
      final ids = await _wishlistService.fetchWishlistedVenueIds();
      if (!mounted) return;
      setState(() {
        wishlistedVenueIds = ids;
      });
    } catch (_) {
      // Keep empty state when wishlist cannot be loaded.
    }
  }

  Future<void> _toggleVenueWishlist(VenueData venue) async {
    final venueId = venue.id;
    if (venueId == null) return;
    if (wishlistBusyVenueIds.contains(venueId)) return;

    final isCurrentlyWishlisted = wishlistedVenueIds.contains(venueId);
    setState(() {
      wishlistBusyVenueIds = {...wishlistBusyVenueIds, venueId};
      if (isCurrentlyWishlisted) {
        wishlistedVenueIds = {...wishlistedVenueIds}..remove(venueId);
      } else {
        wishlistedVenueIds = {...wishlistedVenueIds, venueId};
      }
    });

    try {
      final nowWishlisted = await _wishlistService.toggleVenue(venueId);
      if (!mounted) return;

      setState(() {
        final updated = {...wishlistedVenueIds};
        if (nowWishlisted) {
          updated.add(venueId);
        } else {
          updated.remove(venueId);
        }
        wishlistedVenueIds = updated;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (isCurrentlyWishlisted) {
          wishlistedVenueIds = {...wishlistedVenueIds, venueId};
        } else {
          wishlistedVenueIds = {...wishlistedVenueIds}..remove(venueId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update wishlist: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        wishlistBusyVenueIds = {...wishlistBusyVenueIds}..remove(venueId);
      });
    }
  }

  void _applyFilters() {
    setState(() {
      filteredVenues = List.from(widget.venues);

      // City filter
      if (selectedCity != 'All') {
        filteredVenues = filteredVenues
            .where((v) => v.shortLocation.contains(selectedCity))
            .toList();
      }

      // Budget filter (range slider)
      if (_isBudgetFilterActive) {
        filteredVenues = filteredVenues
            .where(
              (v) =>
                  v.discountedVenuePrice >= selectedMinBudget &&
                  v.discountedVenuePrice <= selectedMaxBudget,
            )
            .toList();
      }

      // Sort
      if (sortBy == 'Price: Low to High') {
        filteredVenues.sort(
          (a, b) => a.discountedVenuePrice.compareTo(b.discountedVenuePrice),
        );
      } else if (sortBy == 'Price: High to Low') {
        filteredVenues.sort(
          (a, b) => b.discountedVenuePrice.compareTo(a.discountedVenuePrice),
        );
      } else if (sortBy == 'Capacity') {
        filteredVenues.sort(
          (a, b) => (b.guestCapacity ?? 0).compareTo(a.guestCapacity ?? 0),
        );
      }
    });
  }

  Future<void> _showBudgetMenu(TapDownDetails details) async {
    final maxSliderValue = categoryMaxBudget > 0
        ? categoryMaxBudget
        : _budgetStep;

    double tempMin = selectedMinBudget.clamp(0, maxSliderValue);
    double tempMax = selectedMaxBudget > 0
        ? selectedMaxBudget.clamp(0, maxSliderValue)
        : maxSliderValue;

    if (tempMax <= tempMin) {
      tempMin = 0;
      tempMax = maxSliderValue;
    }

    RangeValues tempValues = RangeValues(tempMin, tempMax);

    await _showAnchoredDropdown(
      details: details,
      width: 320,
      child: StatefulBuilder(
        builder: (context, setMenuState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Text(
                  'Budget Range',
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff0c1c2c),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '₹${tempValues.start.toInt()} - ₹${tempValues.end.toInt()}',
                  style: GoogleFonts.urbanist(
                    color: const Color(0xff0c1c2c),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: RangeSlider(
                  values: tempValues,
                  min: 0,
                  max: maxSliderValue,
                  divisions: (maxSliderValue / _budgetStep).round(),
                  labels: RangeLabels(
                    '₹${tempValues.start.toInt()}',
                    '₹${tempValues.end.toInt()}',
                  ),
                  activeColor: const Color(0xFF9C27B0),
                  inactiveColor: Colors.grey[300],
                  onChanged: (values) {
                    final snappedStart =
                        ((values.start / _budgetStep).round() * _budgetStep)
                            .clamp(0.0, maxSliderValue);
                    final snappedEnd =
                        ((values.end / _budgetStep).round() * _budgetStep)
                            .clamp(0.0, maxSliderValue);

                    setMenuState(() {
                      if (snappedStart <= snappedEnd) {
                        tempValues = RangeValues(snappedStart, snappedEnd);
                      } else {
                        tempValues = RangeValues(snappedEnd, snappedStart);
                      }
                    });
                  },
                ),
              ),
              if (!hasBudgetData)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'No budget data available for this category.',
                    style: GoogleFonts.urbanist(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.urbanist(color: Colors.grey[600]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedMinBudget = tempValues.start;
                          selectedMaxBudget = tempValues.end;
                        });
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      child: Text(
                        'Apply',
                        style: GoogleFonts.urbanist(
                          color: const Color(0xff0c1c2c),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCityMenu(TapDownDetails details) async {
    final cities = [
      'All',
      ...widget.venues.map((v) => v.shortLocation).toSet(),
    ];

    final selected = await _showRoundedMenu<String>(
      details,
      cities
          .map((city) => PopupMenuItem<String>(value: city, child: Text(city)))
          .toList(),
    );

    if (selected == null) return;
    setState(() {
      selectedCity = selected;
    });
    _applyFilters();
  }

  Future<T?> _showRoundedMenu<T>(
    TapDownDetails details,
    List<PopupMenuEntry<T>> items,
  ) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = details.globalPosition;

    return showMenu<T>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 8,
      color: Colors.white,
      items: items,
    );
  }

  Future<void> _showAnchoredDropdown({
    required TapDownDetails details,
    required Widget child,
    double width = 280,
  }) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = details.globalPosition;
    final left = (position.dx - 20).clamp(8.0, overlay.size.width - width - 8);
    final top = position.dy + 8;

    return showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Dismiss',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, menuChild) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * -8),
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: value,
                          child: menuChild,
                        ),
                      ),
                    ),
                  );
                },
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xff0c1c2c),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SortComponent(
                    selectedValue: sortBy,
                    options: const [
                      'Price: Low to High',
                      'Price: High to Low',
                      'Capacity',
                    ],
                    onChanged: (value) {
                      setState(() {
                        sortBy = value;
                      });
                      _applyFilters();
                    },
                    labelTextStyle: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    activeColor: const Color(0xFF9C27B0),
                    inactiveBorderColor: Colors.grey[300]!,
                    inactiveTextColor: Colors.grey[800]!,
                    inactiveIconColor: Colors.grey[700]!,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'City',
                    icon: Icons.location_city,
                    isSelected: selectedCity != 'All',
                    onTap: () {},
                    onTapDown: _showCityMenu,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Budget',
                    icon: Icons.currency_rupee,
                    isSelected: _isBudgetFilterActive,
                    onTap: () {},
                    onTapDown: _showBudgetMenu,
                  ),
                ],
              ),
            ),
          ),

          // Results count
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${filteredVenues.length} venues found',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Venue list
          Expanded(
            child: filteredVenues.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No venues found',
                          style: GoogleFonts.urbanist(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: filteredVenues.length,
                    itemBuilder: (context, index) {
                      final venue = filteredVenues[index];
                      return _VenueListCard(
                        venue: venue,
                        isWishlisted:
                            venue.id != null &&
                            wishlistedVenueIds.contains(venue.id!),
                        isWishlistBusy:
                            venue.id != null &&
                            wishlistBusyVenueIds.contains(venue.id!),
                        onWishlistTap: () => _toggleVenueWishlist(venue),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VenueDetailPage(venue: venue),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    bool isSelected = false,
    required VoidCallback onTap,
    void Function(TapDownDetails details)? onTapDown,
  }) {
    return GestureDetector(
      onTap: onTapDown == null ? onTap : null,
      onTapDown: onTapDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9C27B0) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF9C27B0) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }
}

/// Venue list card for filtered list view
class _VenueListCard extends StatelessWidget {
  final VenueData venue;
  final VoidCallback onTap;
  final bool isWishlisted;
  final bool isWishlistBusy;
  final VoidCallback? onWishlistTap;

  const _VenueListCard({
    required this.venue,
    required this.onTap,
    this.isWishlisted = false,
    this.isWishlistBusy = false,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  venue.mainImageUrl != null
                      ? Image.network(
                          venue.mainImageUrl!,
                          width: 120,
                          height: 140,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 120,
                          height: 140,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: isWishlistBusy ? null : onWishlistTap,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isWishlistBusy
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.red,
                                    ),
                                  ),
                                )
                              : Icon(
                                  isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 17,
                                  color: Colors.red,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Venue Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff0c1c2c),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue.shortLocation,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (venue.guestCapacity != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Up to ${venue.guestCapacity} guests',
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${venue.discountedVenuePrice.toInt()}',
                          style: GoogleFonts.urbanist(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9C27B0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
