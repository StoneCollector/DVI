import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

/// User service for managing user profiles
class UserService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Get user profile by user ID
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error fetching user profile: $e');
      return null;
    }
  }

  /// Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    final user = SupabaseConfig.currentUser;
    if (user == null) return null;

    return getUserProfile(user.id);
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    Map<String, dynamic>? extraAttributes,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      // Add extra attributes if provided
      if (extraAttributes != null) {
        updateData.addAll(extraAttributes);
      }

      if (updateData.isEmpty) {
        debugPrint('⚠️ No fields to update');
        return;
      }

      await _supabase.from('profiles').update(updateData).eq('id', userId);

      debugPrint('✅ User profile updated');
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _supabase.from('profiles').delete().eq('id', userId);

      debugPrint('✅ User profile deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user profile: $e');
      rethrow;
    }
  }

  /// Check if user has completed profile
  Future<bool> hasCompletedProfile(String userId) async {
    try {
      final profile = await getUserProfile(userId);

      if (profile == null) return false;

      // Check if essential fields are filled
      return profile.fullName.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking profile completion: $e');
      return false;
    }
  }

  /// Stream user profile updates (real-time)
  Stream<UserModel?> streamUserProfile(String userId) {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) {
          if (data.isEmpty) return null;
          return UserModel.fromJson(data.first);
        });
  }
}
