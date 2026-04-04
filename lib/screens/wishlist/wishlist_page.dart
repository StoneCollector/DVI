import 'package:dreamventz/models/venue_models.dart';
import 'package:dreamventz/components/wishlist_item_tile.dart';
import 'package:dreamventz/components/wishlist_state_view.dart';
import 'package:dreamventz/screens/vendors/vendor_profile_page.dart';
import 'package:dreamventz/screens/venues/venue_detail_page.dart';
import 'package:dreamventz/services/venue_service.dart';
import 'package:dreamventz/services/vendor_card_service.dart';
import 'package:dreamventz/services/wishlist_service.dart';
import 'package:dreamventz/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistPage extends StatefulWidget {
  final int refreshSignal;

  const WishlistPage({super.key, this.refreshSignal = 0});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final WishlistService _wishlistService = WishlistService();
  final VenueService _venueService = VenueService();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool isLoading = true;
  String? errorMessage;
  Set<String> removingTargetIds = <String>{};
  List<_WishlistDisplayItem> wishlistItems = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  @override
  void didUpdateWidget(covariant WishlistPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSignal != widget.refreshSignal) {
      _loadWishlist();
    }
  }

  Future<void> _loadWishlist() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final rows = await _wishlistService.fetchWishlistRows();
      final venueIds = rows
          .map((row) => row.venueId)
          .whereType<String>()
          .toSet()
          .toList();
      final vendorCardIds = rows
          .map((row) => row.vendorCardId)
          .whereType<String>()
          .toSet()
          .toList();

      final Map<String, VenueData> venueById = {};
      final Map<String, Map<String, dynamic>> vendorCardById = {};

      if (venueIds.isNotEmpty) {
        final venueResponse = await _supabase
            .from('venue_data')
            .select()
            .inFilter('id', venueIds);

        final galleryResponse = await _supabase
            .from('venue_gallery')
            .select('venue_id, image_filename, display_order')
            .inFilter('venue_id', venueIds)
            .order('display_order', ascending: true);

        final Map<String, String> firstImageByVenueId = {};
        for (final row in (galleryResponse as List)) {
          final venueId = row['venue_id']?.toString();
          final imageFilename = row['image_filename']?.toString();
          if (venueId == null || imageFilename == null) continue;
          firstImageByVenueId.putIfAbsent(venueId, () => imageFilename);
        }

        for (final row in (venueResponse as List)) {
          final venueJson = row as Map<String, dynamic>;
          final venue = VenueData.fromJson(venueJson);
          if (venue.id == null) continue;

          final imageFilename = firstImageByVenueId[venue.id!];
          final galleryImages = imageFilename == null
              ? const <VenueGalleryImage>[]
              : [
                  VenueGalleryImage(
                    venueId: venue.id,
                    imageFilename: imageFilename,
                    imageUrl: _venueService.getGalleryImageUrl(imageFilename),
                    displayOrder: 0,
                  ),
                ];

          venueById[venue.id!] = VenueData(
            id: venue.id,
            vendorId: venue.vendorId,
            name: venue.name,
            description: venue.description,
            category: venue.category,
            latitude: venue.latitude,
            longitude: venue.longitude,
            locationAddress: venue.locationAddress,
            basePrice: venue.basePrice,
            venueDiscountPercent: venue.venueDiscountPercent,
            policies: venue.policies,
            rating: venue.rating,
            reviewCount: venue.reviewCount,
            guestCapacity: venue.guestCapacity,
            uploaderPhone: venue.uploaderPhone,
            uploaderEmail: venue.uploaderEmail,
            vendorName: venue.vendorName,
            createdAt: venue.createdAt,
            updatedAt: venue.updatedAt,
            services: venue.services,
            galleryImages: galleryImages,
          );
        }
      }

      if (vendorCardIds.isNotEmpty) {
        final vendorResponse = await _supabase
            .from('vendor_cards')
            .select()
            .inFilter('id', vendorCardIds);

        for (final row in (vendorResponse as List)) {
          final vendorJson = row as Map<String, dynamic>;
          final id = vendorJson['id']?.toString();
          if (id == null) continue;
          vendorCardById[id] = vendorJson;
        }
      }

      final List<_WishlistDisplayItem> mappedItems = [];
      for (final row in rows) {
        if (row.venueId != null && venueById.containsKey(row.venueId)) {
          final venue = venueById[row.venueId!]!;
          mappedItems.add(
            _WishlistDisplayItem(
              id: row.venueId!,
              createdAt: row.createdAt,
              type: _WishlistItemType.venue,
              title: venue.name,
              subtitle: venue.shortLocation,
              amount: venue.discountedVenuePrice,
              imageUrl: venue.mainImageUrl,
              venue: venue,
            ),
          );
        } else if (row.vendorCardId != null &&
            vendorCardById.containsKey(row.vendorCardId)) {
          final card = vendorCardById[row.vendorCardId!]!;
          final amount =
              (card['discounted_price'] ?? card['original_price'] ?? 0)
                  .toDouble();
          mappedItems.add(
            _WishlistDisplayItem(
              id: row.vendorCardId!,
              createdAt: row.createdAt,
              type: _WishlistItemType.vendor,
              title: card['studio_name']?.toString() ?? 'Vendor',
              subtitle: card['city']?.toString() ?? 'Location unavailable',
              amount: amount,
              imageUrl: VendorCardService.getImageUrl(
                card['image_path']?.toString() ?? '',
              ),
              vendorCard: card,
            ),
          );
        }
      }

      if (!mounted) return;
      setState(() {
        wishlistItems = mappedItems;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Failed to load wishlist: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromWishlist(_WishlistDisplayItem item) async {
    if (removingTargetIds.contains(item.id)) return;

    setState(() {
      removingTargetIds = {...removingTargetIds, item.id};
      wishlistItems = wishlistItems
          .where((entry) => entry.id != item.id)
          .toList();
    });

    try {
      if (item.type == _WishlistItemType.venue) {
        await _wishlistService.removeVenue(item.id);
      } else {
        await _wishlistService.removeVendorCard(item.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        wishlistItems = [...wishlistItems, item]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove wishlist item: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        removingTargetIds = {...removingTargetIds}..remove(item.id);
      });
    }
  }

  Future<void> _openItem(_WishlistDisplayItem item) async {
    if (item.type == _WishlistItemType.venue && item.venue != null) {
      final venueId = item.venue!.id;
      final fullVenue = venueId == null
          ? null
          : await _venueService.getVenueById(venueId);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VenueDetailPage(venue: fullVenue ?? item.venue!),
        ),
      );
      return;
    }

    if (item.type == _WishlistItemType.vendor && item.vendorCard != null) {
      final card = item.vendorCard!;
      final vendorData = {
        'id': card['id'],
        'studio_name': card['studio_name'],
        'city': card['city'],
        'image_path': card['image_path'],
        'service_tags': card['service_tags'] ?? const <String>[],
        'quality_tags': card['quality_tags'] ?? const <String>[],
        'original_price': card['original_price'] ?? 0,
        'discounted_price': card['discounted_price'] ?? 0,
        'rating': 4.5,
        'reviewCount': 0,
      };

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VendorProfilePage(vendorData: vendorData),
        ),
      );
    }
  }

  String _formatInr(double value) {
    return '₹${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f3f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfff5f3f8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Wishlist',
          style: GoogleFonts.urbanist(
            color: const Color(0xff14111e),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff17141f)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.more_vert, color: Color(0xff17141f)),
          SizedBox(width: 14),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWishlist,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? WishlistStateView(
                icon: Icons.error_outline,
                message: errorMessage!,
                iconColor: Colors.red[400],
              )
            : wishlistItems.isEmpty
            ? const WishlistStateView(
                icon: Icons.favorite_border,
                message:
                    'Your wishlist is empty. Tap the heart icon to save venues and vendors.',
                topSpacing: 140,
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                itemCount: wishlistItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = wishlistItems[index];
                  final isRemoving = removingTargetIds.contains(item.id);

                  return WishlistItemTile(
                    typeLabel: item.type == _WishlistItemType.venue
                        ? 'Venue'
                        : 'Vendor',
                    badgeColor: item.type == _WishlistItemType.venue
                        ? const Color(0xFFF3E5F5)
                        : const Color(0xFFFFEBEE),
                    amountColor: item.type == _WishlistItemType.venue
                        ? const Color(0xFF9C27B0)
                        : const Color(0xFFE91E63),
                    title: item.title,
                    subtitle: item.subtitle,
                    amountText: _formatInr(item.amount),
                    imageUrl: item.imageUrl,
                    isRemoving: isRemoving,
                    onTap: () => _openItem(item),
                    onRemove: () => _removeFromWishlist(item),
                  );
                },
              ),
      ),
    );
  }
}

enum _WishlistItemType { venue, vendor }

class _WishlistDisplayItem {
  final String id;
  final DateTime createdAt;
  final _WishlistItemType type;
  final String title;
  final String subtitle;
  final double amount;
  final String? imageUrl;
  final VenueData? venue;
  final Map<String, dynamic>? vendorCard;

  const _WishlistDisplayItem({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.imageUrl,
    this.venue,
    this.vendorCard,
  });
}
