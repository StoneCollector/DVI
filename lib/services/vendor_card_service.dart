import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamventz/models/vendor_card.dart';
import 'package:dreamventz/utils/supabase_config.dart';

class VendorCardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch vendor cards by category
  Future<List<VendorCard>> getVendorCardsByCategory(int categoryId) async {
    try {
      final response = await _supabase
          .from('vendor_cards')
          .select()
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => VendorCard.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching vendor cards: $e');
      rethrow;
    }
  }

  // Get unique cities for a category
  Future<List<String>> getUniqueCities(int categoryId) async {
    try {
      final response = await _supabase
          .from('vendor_cards')
          .select('city')
          .eq('category_id', categoryId);

      final cities = (response as List)
          .map((item) => item['city'] as String)
          .toSet()
          .toList();
      cities.sort();
      return cities;
    } catch (e) {
      print('Error fetching cities: $e');
      return [];
    }
  }

  // Get all unique service tags for a category
  Future<List<String>> getAllServiceTags(int categoryId) async {
    try {
      final response = await _supabase
          .from('vendor_cards')
          .select('service_tags')
          .eq('category_id', categoryId);

      final Set<String> allTags = {};
      for (var item in response as List) {
        final tags = List<String>.from(item['service_tags'] ?? []);
        allTags.addAll(tags);
      }
      
      final tagList = allTags.toList();
      tagList.sort();
      return tagList;
    } catch (e) {
      print('Error fetching service tags: $e');
      return [];
    }
  }

  // Get all unique quality tags for a category
  Future<List<String>> getAllQualityTags(int categoryId) async {
    try {
      final response = await _supabase
          .from('vendor_cards')
          .select('quality_tags')
          .eq('category_id', categoryId);

      final Set<String> allTags = {};
      for (var item in response as List) {
        final tags = List<String>.from(item['quality_tags'] ?? []);
        allTags.addAll(tags);
      }
      
      final tagList = allTags.toList();
      tagList.sort();
      return tagList;
    } catch (e) {
      print('Error fetching quality tags: $e');
      return [];
    }
  }

  // Get full image URL from storage
  static String getImageUrl(String imagePath) {
    return '${SupabaseConfig.projectUrl}/storage/v1/object/public/${SupabaseConfig.vendorImagesBucket}/$imagePath';
  }
}
