/// Model for coordination service
class CoordinationService {
  final String id;
  final String title;
  final String description;
  final double price;
  final String? tag;
  final String? imageUrl;
  final DateTime? createdAt;

  CoordinationService({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.tag,
    this.imageUrl,
    this.createdAt,
  });

  factory CoordinationService.fromJson(Map<String, dynamic> json) {
    return CoordinationService(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      tag: json['tag'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'tag': tag,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Check if service has a tag
  bool get hasTag => tag != null && tag!.isNotEmpty;

  /// Check if service is flagship
  bool get isFlagship => tag?.toUpperCase() == 'FLAGSHIP';

  /// Check if service is new
  bool get isNew => tag?.toUpperCase() == 'NEW';

  /// Get formatted price string
  String get formattedPrice => price.toInt().toString();
}
