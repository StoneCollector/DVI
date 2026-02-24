import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/venue_models.dart';

/// Detailed venue page showing all venue information
class VenueDetailPage extends StatefulWidget {
  final VenueData venue;

  const VenueDetailPage({super.key, required this.venue});

  @override
  State<VenueDetailPage> createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends State<VenueDetailPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    // Start autoscroll for carousel
    if (widget.venue.galleryImages.isNotEmpty) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController.hasClients) {
          final nextPage = (_currentImageIndex + 1) % widget.venue.galleryImages.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          _buildSliverAppBar(context),

          // Venue Details
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVenueHeader(),
                _buildLocationSection(),
                _buildVendorContactSection(),
                if (widget.venue.description != null && widget.venue.description!.isNotEmpty)
                  _buildDescriptionSection(),
                if (widget.venue.services.isNotEmpty) _buildServicesSection(),
                if (widget.venue.galleryImages.length > 1) _buildGallerySection(),
                if (widget.venue.policies != null && widget.venue.policies!.isNotEmpty)
                  _buildPoliciesSection(),
                _buildBookingStepsSection(),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ],
      ),

      // Bottom Book Now Button
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final hasImages = widget.venue.galleryImages.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: const Color(0xff0c1c2c),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: hasImages
            ? Stack(
                children: [
                  // Image Carousel
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: widget.venue.galleryImages.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.venue.galleryImages[index].imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      );
                    },
                  ),

                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Page indicator
                  if (widget.venue.galleryImages.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.venue.galleryImages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Tap to view full screen
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _FullScreenImageViewer(
                              images: widget.venue.galleryImages,
                              initialIndex: _currentImageIndex,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Image Available',
            style: GoogleFonts.urbanist(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Venue Name
          Text(
            widget.venue.name,
            style: GoogleFonts.urbanist(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0c1c2c),
            ),
          ),
          const SizedBox(height: 12),

          // Category Badge
          if (widget.venue.category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xff0c1c2c).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.venue.category!,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff0c1c2c),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Rating and Capacity
          Row(
            children: [
              // Rating
              if (widget.venue.rating != null && widget.venue.reviewCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        widget.venue.ratingDisplay,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff0c1c2c),
                        ),
                      ),
                      Text(
                        ' (${widget.venue.reviewCount})',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(width: 12),

              // Guest Capacity
              if (widget.venue.guestCapacity != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: Colors.blue, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.venue.guestCapacity} guests',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0c1c2c),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: const Color(0xff0c1c2c), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.venue.locationAddress ?? 'Address not provided',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff0c1c2c),
                  ),
                ),
              ],
            ),
          ),
          if (widget.venue.locationAddress != null && widget.venue.locationAddress!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.directions, color: Color(0xff0c1c2c)),
              onPressed: () async {
                final address = Uri.encodeComponent(widget.venue.locationAddress!);
                final url = Uri.parse('geo:0,0?q=$address');
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  // Fallback to web URL if geo: scheme fails
                  final webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
                  await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0c1c2c),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.venue.description!,
            style: GoogleFonts.urbanist(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services & Pricing',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0c1c2c),
            ),
          ),
          const SizedBox(height: 16),

          // Venue base price
          _buildPriceCard(
            'Venue Base Price',
            widget.venue.basePrice,
            widget.venue.venueDiscountPercent,
          ),

          const SizedBox(height: 12),

          // Services
          ...widget.venue.services.map((service) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPriceCard(
                service.serviceName,
                service.price,
                service.discountPercent,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String title, double price, double discount) {
    final hasDiscount = discount > 0;
    final discountedPrice = price * (1 - discount / 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xff0c1c2c),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasDiscount)
                Text(
                  '₹${price.toInt()}',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Row(
                children: [
                  Text(
                    '₹${hasDiscount ? discountedPrice.toInt() : price.toInt()}',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: hasDiscount
                          ? Colors.green[700]
                          : const Color(0xff0c1c2c),
                    ),
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${discount.toInt()}% OFF',
                        style: GoogleFonts.urbanist(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gallery',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0c1c2c),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.venue.galleryImages.length,
              itemBuilder: (context, index) {
                final image = widget.venue.galleryImages[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _FullScreenImageViewer(
                          images: widget.venue.galleryImages,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(image.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliciesSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Policies',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0c1c2c),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.venue.policies!,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStepsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff0c1c2c).withOpacity(0.05),
            Colors.blue[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to Book',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0c1c2c),
            ),
          ),
          const SizedBox(height: 20),
          _buildBookingStep(
            number: '1',
            title: 'Contact Vendor',
            description: 'Reach out via phone or email to discuss your requirements',
            color: Colors.blue,
          ),
          _buildBookingStep(
            number: '2',
            title: 'Visit Venue',
            description: 'Schedule a visit to see the venue in person',
            color: Colors.purple,
          ),
          _buildBookingStep(
            number: '3',
            title: 'Confirm Booking',
            description: 'Finalize details and make the payment to confirm',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStep({
    required String number,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 16, bottom: 16),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff0c1c2c),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorContactSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF3E5F5),
            Color(0xFFFFE6F0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.contact_phone_rounded,
                color: Color(0xFF9C27B0),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Vendor',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff0c1c2c),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Vendor Name
          if (widget.venue.vendorName != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.business_rounded,
                    size: 20,
                    color: Color(0xFF9C27B0),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.venue.vendorName!,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff0c1c2c),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Email
          if (widget.venue.uploaderEmail != null)
            _buildContactItem(
              icon: Icons.email_rounded,
              label: 'Email',
              value: widget.venue.uploaderEmail!,
              onTap: () async {
                final url = Uri.parse('mailto:${widget.venue.uploaderEmail}');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),

          if (widget.venue.uploaderEmail != null && widget.venue.uploaderPhone != null)
            const SizedBox(height: 12),

          // Phone
          if (widget.venue.uploaderPhone != null)
            _buildContactItem(
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: widget.venue.uploaderPhone!,
              onTap: () async {
                final url = Uri.parse('tel:${widget.venue.uploaderPhone}');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),

          const SizedBox(height: 16),

          // Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF9C27B0),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Contact the vendor directly for bookings and inquiries',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF9C27B0), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff0c1c2c),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final totalPrice =
        widget.venue.discountedVenuePrice +
        widget.venue.services.fold(
          0.0,
          (sum, service) => sum + service.discountedPrice,
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '₹${totalPrice.toInt()}',
                    style: GoogleFonts.urbanist(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff0c1c2c),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to booking page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking feature coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0c1c2c),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Book Now',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Full-screen image viewer with zoom
class _FullScreenImageViewer extends StatefulWidget {
  final List<VenueGalleryImage> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image viewer
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.images[index].imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Page indicator
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
