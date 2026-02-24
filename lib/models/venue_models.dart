/// Model representing a venue for customer viewing
class VenueData {
  final String? id;
  final String vendorId;
  final String name;
  final String? description;
  final String? category;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final double basePrice;
  final double venueDiscountPercent;
  final String? policies;
  final double? rating;
  final int reviewCount;
  final int? guestCapacity; // Will be inferred from services or set manually
  final String? uploaderPhone;
  final String? uploaderEmail;
  final String? vendorName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Related data (loaded separately)
  List<VenueServiceItem> services;
  List<VenueGalleryImage> galleryImages;

  VenueData({
    this.id,
    required this.vendorId,
    required this.name,
    this.description,
    this.category,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.basePrice = 0,
    this.venueDiscountPercent = 0,
    this.policies,
    this.rating,
    this.reviewCount = 0,
    this.guestCapacity,
    this.uploaderPhone,
    this.uploaderEmail,
    this.vendorName,
    this.createdAt,
    this.updatedAt,
    this.services = const [],
    this.galleryImages = const [],
  });

  factory VenueData.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse capacity as int
    int? parseCapacity(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }
    
    return VenueData(
      id: json['id'],
      vendorId: json['vendor_id'],
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationAddress: json['location_address'],
      basePrice: (json['base_price'] ?? 0).toDouble(),
      venueDiscountPercent: (json['venue_discount_percent'] ?? 0).toDouble(),
      policies: json['policies'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'] ?? 0,
      guestCapacity: parseCapacity(json['capacity'] ?? json['guest_capacity']),
      uploaderPhone: json['uploader_phone'],
      uploaderEmail: json['uploader_email'],
      vendorName: json['vendor_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Calculate discounted venue price
  double get discountedVenuePrice {
    return basePrice * (1 - venueDiscountPercent / 100);
  }

  /// Get rating display text
  String get ratingDisplay {
    if (rating == null || reviewCount == 0) {
      return 'New';
    }
    return '${rating!.toStringAsFixed(1)}';
  }

  /// Get the main image URL (first gallery image)
  String? get mainImageUrl {
    if (galleryImages.isEmpty) return null;
    return galleryImages.first.imageUrl;
  }

  /// Get short location (city name)
  String get shortLocation {
    if (locationAddress == null) return 'Location TBD';
    // Extract city name (e.g., "Mumbai" from "Andheri, Mumbai")
    final parts = locationAddress!.split(',');
    if (parts.length > 1) {
      return parts.last.trim();
    }
    return locationAddress!;
  }
}

/// Model representing a service offered at a venue
class VenueServiceItem {
  final String? id;
  final String? venueId;
  final String serviceName;
  final double price;
  final double discountPercent;
  final DateTime? createdAt;

  VenueServiceItem({
    this.id,
    this.venueId,
    required this.serviceName,
    required this.price,
    this.discountPercent = 0,
    this.createdAt,
  });

  factory VenueServiceItem.fromJson(Map<String, dynamic> json) {
    return VenueServiceItem(
      id: json['id'],
      venueId: json['venue_id'],
      serviceName: json['service_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPercent: (json['discount_percent'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Calculate discounted price
  double get discountedPrice {
    return price * (1 - discountPercent / 100);
  }
}

/// Model representing an image in venue gallery
class VenueGalleryImage {
  final String? id;
  final String? venueId;
  final String imageFilename;
  final String imageUrl; // Public URL
  final int displayOrder;
  final DateTime? createdAt;

  VenueGalleryImage({
    this.id,
    this.venueId,
    required this.imageFilename,
    required this.imageUrl,
    this.displayOrder = 0,
    this.createdAt,
  });

  factory VenueGalleryImage.fromJson(
    Map<String, dynamic> json,
    String publicUrl,
  ) {
    return VenueGalleryImage(
      id: json['id'],
      venueId: json['venue_id'],
      imageFilename: json['image_filename'] ?? '',
      imageUrl: publicUrl,
      displayOrder: json['display_order'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
