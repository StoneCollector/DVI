import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/coordination_service_model.dart';

/// Service for fetching coordination services
class CoordinationServiceService {
  final _supabase = Supabase.instance.client;

  // Storage bucket name for coordination service images
  static const String _storageBucket = 'coordination_services';

  /// Fetch all coordination services
  Future<List<CoordinationService>> getAllServices() async {
    try {
      final response = await _supabase
          .from('coordination_services')
          .select()
          .order('created_at', ascending: true);

      final services = (response as List).map((e) {
        final service = CoordinationService.fromJson(e);
        // Get public URL for image if imageUrl is provided
        if (service.imageUrl != null && service.imageUrl!.isNotEmpty) {
          // Extract filename from path (e.g., 'coordination_services/catering.jpeg' -> 'catering.jpeg')
          final filename = service.imageUrl!.contains('/')
              ? service.imageUrl!.split('/').last
              : service.imageUrl!;
          final publicUrl = getImageUrl(filename);
          return CoordinationService(
            id: service.id,
            title: service.title,
            description: service.description,
            price: service.price,
            tag: service.tag,
            imageUrl: publicUrl,
            createdAt: service.createdAt,
          );
        }
        return service;
      }).toList();

      return services;
    } catch (e) {
      debugPrint('Error fetching coordination services: $e');
      return [];
    }
  }

  /// Fetch a single service by ID
  Future<CoordinationService?> getServiceById(String serviceId) async {
    try {
      final response = await _supabase
          .from('coordination_services')
          .select()
          .eq('id', serviceId)
          .single();

      final service = CoordinationService.fromJson(response);
      // Get public URL for image if imageUrl is provided
      if (service.imageUrl != null && service.imageUrl!.isNotEmpty) {
        final filename = service.imageUrl!.contains('/')
            ? service.imageUrl!.split('/').last
            : service.imageUrl!;
        final publicUrl = getImageUrl(filename);
        return CoordinationService(
          id: service.id,
          title: service.title,
          description: service.description,
          price: service.price,
          tag: service.tag,
          imageUrl: publicUrl,
          createdAt: service.createdAt,
        );
      }
      return service;
    } catch (e) {
      debugPrint('Error fetching coordination service: $e');
      return null;
    }
  }

  /// Get public URL for an image
  String getImageUrl(String filename) {
    return _supabase.storage.from(_storageBucket).getPublicUrl(filename);
  }
}
