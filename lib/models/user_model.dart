/// User model representing user data
/// Extensible for future attributes
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Extensible attributes - store any additional data here
  final Map<String, dynamic> extraAttributes;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
    this.extraAttributes = const {},
  });

  /// Create UserModel from JSON (from Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extract known fields
    final knownFields = {
      'id',
      'email',
      'full_name',
      'phone',
      'avatar_url',
      'role',
      'created_at',
      'updated_at',
    };

    // Extract extra attributes (any field not in knownFields)
    final extraAttributes = Map<String, dynamic>.from(json)
      ..removeWhere((key, value) => knownFields.contains(key));

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      extraAttributes: extraAttributes,
    );
  }

  /// Convert UserModel to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    // Add extra attributes
    json.addAll(extraAttributes.cast<String, dynamic>());

    return json;
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? extraAttributes,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      extraAttributes: extraAttributes ?? this.extraAttributes,
    );
  }

  /// Get an extra attribute by key
  dynamic getExtraAttribute(String key) {
    return extraAttributes[key];
  }

  /// Check if user has a specific role
  bool hasRole(String checkRole) {
    return role == checkRole;
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is organizer
  bool get isOrganizer => role == 'organizer';

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
