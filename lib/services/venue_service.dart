import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/venue_models.dart';

/// Service for fetching venue data for customers
class VenueService {
  final _supabase = Supabase.instance.client;

  // Storage bucket name for venue images
  static const String _storageBucket = 'venue_images';

  /// Fetch all public venues (approved venues only)
  Future<List<VenueData>> getAllPublicVenues() async {
    try {
      final response = await _supabase
          .from('venue_data')
          .select()
          .order('created_at', ascending: false);

      final venues = (response as List)
          .map((e) => VenueData.fromJson(e))
          .toList();

      // Load services and gallery for each venue
      for (var i = 0; i < venues.length; i++) {
        final services = await getVenueServices(venues[i].id!);
        final gallery = await getVenueGallery(venues[i].id!);

        venues[i] = VenueData(
          id: venues[i].id,
          vendorId: venues[i].vendorId,
          name: venues[i].name,
          description: venues[i].description,
          category: venues[i].category,
          latitude: venues[i].latitude,
          longitude: venues[i].longitude,
          locationAddress: venues[i].locationAddress,
          basePrice: venues[i].basePrice,
          venueDiscountPercent: venues[i].venueDiscountPercent,
          policies: venues[i].policies,
          rating: venues[i].rating,
          reviewCount: venues[i].reviewCount,
          guestCapacity: venues[i].guestCapacity,
          createdAt: venues[i].createdAt,
          updatedAt: venues[i].updatedAt,
          services: services,
          galleryImages: gallery,
        );
      }

      return venues;
    } catch (e) {
      debugPrint('Error fetching venues: $e');
      return [];
    }
  }

  /// Get venues grouped by category
  Future<Map<String, List<VenueData>>> getVenuesByCategory() async {
    final allVenues = await getAllPublicVenues();
    final Map<String, List<VenueData>> categorizedVenues = {};

    // Define category order
    final categories = [
      'Wedding Venue',
      'Corporate Event Space',
      'Party Hall',
      'Celebration Venue',
      'Outdoor Venue',
      'Banquet Hall',
      'Conference Center',
      'Other',
    ];

    // Initialize all categories
    for (final category in categories) {
      categorizedVenues[category] = [];
    }

    // Group venues by category
    for (final venue in allVenues) {
      final category = venue.category ?? 'Other';
      if (categorizedVenues.containsKey(category)) {
        categorizedVenues[category]!.add(venue);
      } else {
        categorizedVenues['Other']!.add(venue);
      }
    }

    // Remove empty categories
    categorizedVenues.removeWhere((key, value) => value.isEmpty);

    return categorizedVenues;
  }

  /// Get a single venue by ID with all related data
  Future<VenueData?> getVenueById(String venueId) async {
    try {
      final response = await _supabase
          .from('venue_data')
          .select()
          .eq('id', venueId)
          .single();

      final venue = VenueData.fromJson(response);
      final services = await getVenueServices(venueId);
      final gallery = await getVenueGallery(venueId);

      return VenueData(
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
        createdAt: venue.createdAt,
        updatedAt: venue.updatedAt,
        services: services,
        galleryImages: gallery,
      );
    } catch (e) {
      debugPrint('Error fetching venue: $e');
      return null;
    }
  }

  /// Get all services for a venue
  Future<List<VenueServiceItem>> getVenueServices(String venueId) async {
    try {
      final response = await _supabase
          .from('venue_services')
          .select()
          .eq('venue_id', venueId)
          .order('created_at');

      return (response as List)
          .map((e) => VenueServiceItem.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching venue services: $e');
      return [];
    }
  }

  /// Get gallery images for a venue
  Future<List<VenueGalleryImage>> getVenueGallery(String venueId) async {
    try {
      final response = await _supabase
          .from('venue_gallery')
          .select()
          .eq('venue_id', venueId)
          .order('display_order');

      return (response as List).map((e) {
        final filename = e['image_filename'];
        final publicUrl = getGalleryImageUrl(filename);
        return VenueGalleryImage.fromJson(e, publicUrl);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching venue gallery: $e');
      return [];
    }
  }

  /// Get public URL for a gallery image
  String getGalleryImageUrl(String filename) {
    return _supabase.storage.from(_storageBucket).getPublicUrl(filename);
  }
}
