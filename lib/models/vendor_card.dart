class VendorCard {
  final String id;
  final String vendorId;
  final int categoryId;
  final String studioName;
  final String city;
  final String imagePath;
  final List<String> serviceTags;
  final List<String> qualityTags;
  final double originalPrice;
  final double discountedPrice;
  final DateTime createdAt;

  VendorCard({
    required this.id,
    required this.vendorId,
    required this.categoryId,
    required this.studioName,
    required this.city,
    required this.imagePath,
    required this.serviceTags,
    required this.qualityTags,
    required this.originalPrice,
    required this.discountedPrice,
    required this.createdAt,
  });

  // Calculate discount percentage
  int get discountPercent {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100).round();
  }

  // Format discounted price in Indian style
  String get formattedDiscountedPrice {
    return '₹${discountedPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  // Format original price in Indian style
  String get formattedOriginalPrice {
    return '₹${originalPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  factory VendorCard.fromJson(Map<String, dynamic> json) {
    // Parse numeric values safely
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.parse(value.toString());
    }
    
    return VendorCard(
      id: json['id'].toString(),
      vendorId: json['vendor_id'].toString(),
      categoryId: json['category_id'] is int ? json['category_id'] : int.parse(json['category_id'].toString()),
      studioName: json['studio_name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      imagePath: json['image_path']?.toString() ?? '',
      serviceTags: List<String>.from(json['service_tags'] ?? []),
      qualityTags: List<String>.from(json['quality_tags'] ?? []),
      originalPrice: parseDouble(json['original_price']),
      discountedPrice: parseDouble(json['discounted_price']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'category_id': categoryId,
      'studio_name': studioName,
      'city': city,
      'image_path': imagePath,
      'service_tags': serviceTags,
      'quality_tags': qualityTags,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
