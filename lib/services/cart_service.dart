import 'package:dreamventz/config/supabase_config.dart';
import 'package:dreamventz/models/cart_item.dart';
import 'package:dreamventz/models/venue_models.dart';
import 'package:dreamventz/services/vendor_card_service.dart';
import 'package:dreamventz/services/venue_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final VenueService _venueService = VenueService();

  User _requireUser() {
    final user = SupabaseConfig.currentUser;
    if (user == null) {
      throw Exception('Please log in to use the cart.');
    }
    return user;
  }

  Future<void> addVenueToCart({
    required String venueId,
    required int addQuantity,
  }) async {
    if (addQuantity <= 0) {
      throw Exception('Quantity must be greater than 0.');
    }

    final user = _requireUser();

    final venueResponse = await _supabase
        .from('venue_data')
        .select('capacity')
        .eq('id', venueId)
        .maybeSingle();

    if (venueResponse == null) {
      throw Exception('Venue not found.');
    }

    final int? capacity = (venueResponse['capacity'] as num?)?.toInt();

    final existingResponse = await _supabase
        .from('cart')
        .select('cart_id, quantity, hours')
        .eq('user_id', user.id)
        .eq('venue_id', venueId)
        .limit(1);

    final List existingRows = existingResponse as List;
    if (existingRows.isNotEmpty) {
      final existing = existingRows.first as Map<String, dynamic>;
      final int existingQuantity = (existing['quantity'] as num?)?.toInt() ?? 0;
      final int nextQuantity = existingQuantity + addQuantity;

      if (capacity != null && nextQuantity > capacity) {
        throw Exception(
          'Guest count cannot exceed venue capacity ($capacity).',
        );
      }

      await _supabase
          .from('cart')
          .update({'quantity': nextQuantity})
          .eq('cart_id', existing['cart_id'].toString());
      return;
    }

    if (capacity != null && addQuantity > capacity) {
      throw Exception('Guest count cannot exceed venue capacity ($capacity).');
    }

    await _supabase.from('cart').insert({
      'user_id': user.id,
      'venue_id': venueId,
      'quantity': addQuantity,
      'hours': 1,
    });
  }

  Future<void> addVendorToCart({
    required String vendorCardId,
    required int addHours,
  }) async {
    if (addHours <= 0 || addHours > 12) {
      throw Exception('Hours must be between 1 and 12.');
    }

    final user = _requireUser();

    final existingResponse = await _supabase
        .from('cart')
        .select('cart_id, quantity, hours')
        .eq('user_id', user.id)
        .eq('vendor_card_id', vendorCardId)
        .limit(1);

    final List existingRows = existingResponse as List;
    if (existingRows.isNotEmpty) {
      final existing = existingRows.first as Map<String, dynamic>;
      final int existingHours = (existing['hours'] as num?)?.toInt() ?? 1;
      final int nextHours = existingHours + addHours;

      if (nextHours > 12) {
        throw Exception('Hours cannot exceed 12.');
      }

      await _supabase
          .from('cart')
          .update({'hours': nextHours, 'quantity': 1})
          .eq('cart_id', existing['cart_id'].toString());
      return;
    }

    await _supabase.from('cart').insert({
      'user_id': user.id,
      'vendor_card_id': vendorCardId,
      'quantity': 1,
      'hours': addHours,
    });
  }

  Future<void> updateVenueQuantity({
    required String cartId,
    required String venueId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than 0.');
    }

    final venueResponse = await _supabase
        .from('venue_data')
        .select('capacity')
        .eq('id', venueId)
        .maybeSingle();

    if (venueResponse == null) {
      throw Exception('Venue not found.');
    }

    final int? capacity = (venueResponse['capacity'] as num?)?.toInt();
    if (capacity != null && quantity > capacity) {
      throw Exception('Guest count cannot exceed venue capacity ($capacity).');
    }

    await _supabase
        .from('cart')
        .update({'quantity': quantity})
        .eq('cart_id', cartId)
        .eq('venue_id', venueId);
  }

  Future<void> updateVendorHours({
    required String cartId,
    required String vendorCardId,
    required int hours,
  }) async {
    if (hours <= 0 || hours > 12) {
      throw Exception('Hours must be between 1 and 12.');
    }

    await _supabase
        .from('cart')
        .update({'hours': hours, 'quantity': 1})
        .eq('cart_id', cartId)
        .eq('vendor_card_id', vendorCardId);
  }

  Future<void> removeCartItem(String cartId) async {
    _requireUser();
    await _supabase.from('cart').delete().eq('cart_id', cartId);
  }

  Future<List<CartDisplayItem>> fetchCartDisplayItems() async {
    final user = _requireUser();
    final response = await _supabase
        .from('cart')
        .select(
          'cart_id, user_id, venue_id, vendor_card_id, quantity, hours, created_at, updated_at',
        )
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    final rows = (response as List)
        .map((row) => CartItemRow.fromJson(row as Map<String, dynamic>))
        .toList();

    if (rows.isEmpty) {
      return [];
    }

    final venueIds = rows
        .where((row) => row.venueId != null)
        .map((row) => row.venueId!)
        .toSet()
        .toList();

    final vendorIds = rows
        .where((row) => row.vendorCardId != null)
        .map((row) => row.vendorCardId!)
        .toSet()
        .toList();

    final Map<String, VenueData> venueById = {};
    final Map<String, String> firstVenueImageById = {};
    final Map<String, Map<String, dynamic>> vendorById = {};

    if (venueIds.isNotEmpty) {
      final venueResponse = await _supabase
          .from('venue_data')
          .select()
          .inFilter('id', venueIds);

      for (final row in (venueResponse as List)) {
        final venue = VenueData.fromJson(row as Map<String, dynamic>);
        if (venue.id != null) {
          venueById[venue.id!] = venue;
        }
      }

      final galleryResponse = await _supabase
          .from('venue_gallery')
          .select('venue_id, image_filename, display_order')
          .inFilter('venue_id', venueIds)
          .order('display_order', ascending: true);

      for (final row in (galleryResponse as List)) {
        final map = row as Map<String, dynamic>;
        final venueId = map['venue_id']?.toString();
        final fileName = map['image_filename']?.toString();
        if (venueId == null || fileName == null) continue;
        firstVenueImageById.putIfAbsent(venueId, () => fileName);
      }
    }

    if (vendorIds.isNotEmpty) {
      final vendorResponse = await _supabase
          .from('vendor_cards')
          .select()
          .inFilter('id', vendorIds);

      for (final row in (vendorResponse as List)) {
        final map = row as Map<String, dynamic>;
        final id = map['id']?.toString();
        if (id == null) continue;
        vendorById[id] = map;
      }
    }

    final items = <CartDisplayItem>[];

    for (final row in rows) {
      if (row.venueId != null && venueById.containsKey(row.venueId)) {
        final venue = venueById[row.venueId!]!;
        final fileName = firstVenueImageById[row.venueId!];
        final imageUrl = fileName == null
            ? null
            : _venueService.getGalleryImageUrl(fileName);

        items.add(
          CartDisplayItem(
            cartId: row.cartId,
            itemType: CartItemType.venue,
            itemId: row.venueId!,
            title: venue.name,
            meta: venue.shortLocation,
            tag: venue.category ?? 'Venue',
            imageUrl: imageUrl,
            quantity: row.quantity,
            hours: row.hours,
            unitPrice: venue.discountedVenuePrice.toInt(),
            maxQuantity: venue.guestCapacity,
          ),
        );
        continue;
      }

      if (row.vendorCardId != null &&
          vendorById.containsKey(row.vendorCardId)) {
        final vendor = vendorById[row.vendorCardId!]!;
        final num discounted =
            (vendor['discounted_price'] ?? vendor['original_price'] ?? 0)
                as num;

        final serviceTags =
            (vendor['service_tags'] as List?)
                ?.map((tag) => tag.toString())
                .toList() ??
            const <String>[];

        items.add(
          CartDisplayItem(
            cartId: row.cartId,
            itemType: CartItemType.vendor,
            itemId: row.vendorCardId!,
            title: vendor['studio_name']?.toString() ?? 'Vendor',
            meta: vendor['city']?.toString(),
            tag: serviceTags.isNotEmpty ? serviceTags.first : 'Vendor Service',
            imageUrl: VendorCardService.getImageUrl(
              vendor['image_path']?.toString() ?? '',
            ),
            quantity: row.quantity,
            hours: row.hours,
            unitPrice: discounted.toInt(),
            maxQuantity: null,
          ),
        );
      }
    }

    return items;
  }
}
