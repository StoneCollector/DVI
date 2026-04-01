import 'package:dreamventz/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistRow {
  final String wishlistId;
  final String userId;
  final String? venueId;
  final String? vendorCardId;
  final DateTime createdAt;

  const WishlistRow({
    required this.wishlistId,
    required this.userId,
    required this.venueId,
    required this.vendorCardId,
    required this.createdAt,
  });

  bool get isVenue => venueId != null;
  bool get isVendorCard => vendorCardId != null;

  factory WishlistRow.fromJson(Map<String, dynamic> json) {
    return WishlistRow(
      wishlistId: json['wishlist_id'].toString(),
      userId: json['user_id'].toString(),
      venueId: json['venue_id']?.toString(),
      vendorCardId: json['vendor_card_id']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class WishlistService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  User _requireUser() {
    final user = SupabaseConfig.currentUser;
    if (user == null) {
      throw Exception('Please log in to manage wishlist.');
    }
    return user;
  }

  Future<Set<String>> fetchWishlistedVendorCardIds() async {
    final user = _requireUser();
    final response = await _supabase
        .from('wishlist')
        .select('vendor_card_id')
        .eq('user_id', user.id)
        .not('vendor_card_id', 'is', null);

    return (response as List)
        .map((row) => row['vendor_card_id']?.toString())
        .whereType<String>()
        .toSet();
  }

  Future<Set<String>> fetchWishlistedVenueIds() async {
    final user = _requireUser();
    final response = await _supabase
        .from('wishlist')
        .select('venue_id')
        .eq('user_id', user.id)
        .not('venue_id', 'is', null);

    return (response as List)
        .map((row) => row['venue_id']?.toString())
        .whereType<String>()
        .toSet();
  }

  Future<List<WishlistRow>> fetchWishlistRows() async {
    final user = _requireUser();
    final response = await _supabase
        .from('wishlist')
        .select('wishlist_id, user_id, venue_id, vendor_card_id, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => WishlistRow.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<bool> toggleVendorCard(String vendorCardId) async {
    final user = _requireUser();
    final existing = await _supabase
        .from('wishlist')
        .select('wishlist_id')
        .eq('user_id', user.id)
        .eq('vendor_card_id', vendorCardId)
        .limit(1);

    final existingRows = existing as List;
    if (existingRows.isNotEmpty) {
      final wishlistId = existingRows.first['wishlist_id'].toString();
      await _supabase.from('wishlist').delete().eq('wishlist_id', wishlistId);
      return false;
    }

    await _supabase.from('wishlist').insert({
      'user_id': user.id,
      'vendor_card_id': vendorCardId,
    });
    return true;
  }

  Future<bool> toggleVenue(String venueId) async {
    final user = _requireUser();
    final existing = await _supabase
        .from('wishlist')
        .select('wishlist_id')
        .eq('user_id', user.id)
        .eq('venue_id', venueId)
        .limit(1);

    final existingRows = existing as List;
    if (existingRows.isNotEmpty) {
      final wishlistId = existingRows.first['wishlist_id'].toString();
      await _supabase.from('wishlist').delete().eq('wishlist_id', wishlistId);
      return false;
    }

    await _supabase.from('wishlist').insert({
      'user_id': user.id,
      'venue_id': venueId,
    });
    return true;
  }

  Future<void> removeVendorCard(String vendorCardId) async {
    final user = _requireUser();
    await _supabase
        .from('wishlist')
        .delete()
        .eq('user_id', user.id)
        .eq('vendor_card_id', vendorCardId);
  }

  Future<void> removeVenue(String venueId) async {
    final user = _requireUser();
    await _supabase
        .from('wishlist')
        .delete()
        .eq('user_id', user.id)
        .eq('venue_id', venueId);
  }
}
