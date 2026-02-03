import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/venue_models.dart';
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
  List<VenueData> filteredVenues = [];

  // Filter states
  String sortBy = 'Price: Low to High';
  String selectedCity = 'All';
  String budgetRange = 'All';

  @override
  void initState() {
    super.initState();
    filteredVenues = List.from(widget.venues);
    _applyFilters();
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

      // Budget filter
      if (budgetRange == 'Under 50k') {
        filteredVenues = filteredVenues
            .where((v) => v.discountedVenuePrice < 50000)
            .toList();
      } else if (budgetRange == '50k-1L') {
        filteredVenues = filteredVenues
            .where(
              (v) =>
                  v.discountedVenuePrice >= 50000 &&
                  v.discountedVenuePrice <= 100000,
            )
            .toList();
      } else if (budgetRange == 'Above 1L') {
        filteredVenues = filteredVenues
            .where((v) => v.discountedVenuePrice > 100000)
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

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Sort by',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            color: const Color(0xff0c1c2c),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('Price: Low to High'),
            _buildSortOption('Price: High to Low'),
            _buildSortOption('Capacity'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String option) {
    return RadioListTile<String>(
      title: Text(
        option,
        style: GoogleFonts.urbanist(color: const Color(0xff0c1c2c)),
      ),
      value: option,
      groupValue: sortBy,
      activeColor: const Color(0xFF9C27B0),
      onChanged: (value) {
        setState(() {
          sortBy = value!;
        });
        Navigator.pop(context);
        _applyFilters();
      },
    );
  }

  void _showBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Budget Range',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            color: const Color(0xff0c1c2c),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBudgetOption('All'),
            _buildBudgetOption('Under 50k'),
            _buildBudgetOption('50k-1L'),
            _buildBudgetOption('Above 1L'),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetOption(String option) {
    return RadioListTile<String>(
      title: Text(
        option,
        style: GoogleFonts.urbanist(color: const Color(0xff0c1c2c)),
      ),
      value: option,
      groupValue: budgetRange,
      activeColor: const Color(0xFF9C27B0),
      onChanged: (value) {
        setState(() {
          budgetRange = value!;
        });
        Navigator.pop(context);
        _applyFilters();
      },
    );
  }

  void _showCityDialog() {
    // Get unique cities from venues
    final cities = [
      'All',
      ...widget.venues.map((v) => v.shortLocation).toSet(),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Select City',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            color: const Color(0xff0c1c2c),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: cities.map((city) {
              return RadioListTile<String>(
                title: Text(
                  city,
                  style: GoogleFonts.urbanist(color: const Color(0xff0c1c2c)),
                ),
                value: city,
                groupValue: selectedCity,
                activeColor: const Color(0xFF9C27B0),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value!;
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
              );
            }).toList(),
          ),
        ),
      ),
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
                  _buildFilterChip(
                    label: 'Sort',
                    icon: Icons.sort,
                    onTap: _showSortDialog,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'City',
                    icon: Icons.location_city,
                    onTap: _showCityDialog,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Budget',
                    icon: Icons.currency_rupee,
                    onTap: _showBudgetDialog,
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
  }) {
    return GestureDetector(
      onTap: onTap,
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

  const _VenueListCard({required this.venue, required this.onTap});

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
              child: venue.mainImageUrl != null
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
