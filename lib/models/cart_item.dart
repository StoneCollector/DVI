enum CartItemType { venue, vendor }

class CartItemRow {
  final String cartId;
  final String userId;
  final String? venueId;
  final String? vendorCardId;
  final int quantity;
  final int hours;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CartItemRow({
    required this.cartId,
    required this.userId,
    required this.venueId,
    required this.vendorCardId,
    required this.quantity,
    required this.hours,
    required this.createdAt,
    this.updatedAt,
  });

  CartItemType get itemType {
    if (venueId != null) return CartItemType.venue;
    return CartItemType.vendor;
  }

  factory CartItemRow.fromJson(Map<String, dynamic> json) {
    return CartItemRow(
      cartId: json['cart_id'].toString(),
      userId: json['user_id'].toString(),
      venueId: json['venue_id']?.toString(),
      vendorCardId: json['vendor_card_id']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      hours: (json['hours'] as num?)?.toInt() ?? 1,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class CartDisplayItem {
  final String cartId;
  final CartItemType itemType;
  final String itemId;
  final String title;
  final String? meta;
  final String tag;
  final String? imageUrl;
  final int quantity;
  final int hours;
  final int unitPrice;
  final int? maxQuantity;

  const CartDisplayItem({
    required this.cartId,
    required this.itemType,
    required this.itemId,
    required this.title,
    required this.meta,
    required this.tag,
    required this.imageUrl,
    required this.quantity,
    required this.hours,
    required this.unitPrice,
    this.maxQuantity,
  });

  int get displayCount {
    return itemType == CartItemType.venue ? quantity : hours;
  }

  String get displayLabel {
    return itemType == CartItemType.venue ? 'Guests' : 'Hours';
  }

  int get lineTotal {
    if (itemType == CartItemType.venue) {
      // Guest count is informational for venues and should not scale price.
      return unitPrice;
    }
    return unitPrice * hours;
  }
}
