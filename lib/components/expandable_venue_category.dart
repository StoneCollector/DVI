import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/venue_models.dart';
import 'venue_card.dart';

/// Expandable venue category widget with smooth animations
/// Shows category header with count, expands to show venue cards
class ExpandableVenueCategory extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;
  final List<VenueData> venues;
  final Function(VenueData)? onVenueTap;

  const ExpandableVenueCategory({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.venues,
    this.onVenueTap,
  });

  /// Get icon for category
  static IconData getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'wedding venue':
        return Icons.celebration;
      case 'corporate event space':
        return Icons.business_center;
      case 'party hall':
        return Icons.party_mode;
      case 'celebration venue':
        return Icons.cake;
      case 'outdoor venue':
        return Icons.nature_people;
      case 'banquet hall':
        return Icons.restaurant;
      case 'conference center':
        return Icons.meeting_room;
      default:
        return Icons.place;
    }
  }

  @override
  State<ExpandableVenueCategory> createState() =>
      _ExpandableVenueCategoryState();
}

class _ExpandableVenueCategoryState extends State<ExpandableVenueCategory>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotationAnimation =
        Tween<double>(
          begin: 0,
          end: 0.5, // 180 degrees
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category Header (Always visible)
          _buildCategoryHeader(),

          // Expandable content (venues list)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded ? _buildVenuesList() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return InkWell(
      onTap: _toggleExpansion,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Category Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff0c1c2c).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.categoryIcon,
                color: const Color(0xff0c1c2c),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Category Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.categoryName,
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff0c1c2c),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.venues.length} ${widget.venues.length == 1 ? 'venue' : 'venues'}',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Expand/Collapse Icon
            RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: const Color(0xff0c1c2c),
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenuesList() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 8, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),

          // Horizontal scrollable venue cards
          SizedBox(
            height: 490, // Adjust based on card height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.venues.length,
              itemBuilder: (context, index) {
                final venue = widget.venues[index];
                return VenueCard(
                  venue: venue,
                  onTap: () => widget.onVenueTap?.call(venue),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
