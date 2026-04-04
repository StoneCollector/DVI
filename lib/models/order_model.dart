class OrderItem {
  final String title;
  final String tag;
  final int quantity;
  final int hours;
  final int unitPrice;
  final String? imageUrl;
  final String itemType;

  OrderItem({
    required this.title,
    required this.tag,
    required this.quantity,
    required this.hours,
    required this.unitPrice,
    this.imageUrl,
    required this.itemType,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      title: json['title'] ?? '',
      tag: json['tag'] ?? '',
      quantity: json['quantity'] ?? 1,
      hours: json['hours'] ?? 1,
      unitPrice: json['unitPrice'] ?? 0,
      imageUrl: json['imageUrl'],
      itemType: json['itemType'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'tag': tag,
      'quantity': quantity,
      'hours': hours,
      'unitPrice': unitPrice,
      'imageUrl': imageUrl,
      'itemType': itemType,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final num totalAmount;
  final String status;
  final List<OrderItem> items;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.items,
    this.paymentId,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      totalAmount: json['total_amount'] ?? 0,
      status: json['status']?.toString() ?? 'Pending',
      items: itemsList.map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList(),
      paymentId: json['razorpay_payment_id']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}
