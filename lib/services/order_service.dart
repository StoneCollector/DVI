import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamventz/models/order_model.dart';
import 'package:dreamventz/models/cart_item.dart';
import 'package:dreamventz/config/supabase_config.dart';
import 'dart:convert';

class OrderService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<void> createOrder(List<CartDisplayItem> cartItems, int totalAmount, String paymentId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final itemsJson = cartItems.map((item) {
      return {
        'title': item.title,
        'tag': item.tag,
        'quantity': item.quantity,
        'hours': item.hours,
        'unitPrice': item.unitPrice,
        'imageUrl': item.imageUrl,
        'itemType': item.itemType.toString().split('.').last, // 'venue' or 'vendor'
      };
    }).toList();

    await _client.from('orderslist').insert({
      'user_id': userId,
      'total_amount': totalAmount,
      'items': itemsJson,
      'razorpay_payment_id': paymentId,
      'status': 'Payment Received',
    });
  }

  Future<List<OrderModel>> fetchActiveOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('orderslist')
        .select()
        .eq('user_id', userId)
        .not('status', 'eq', 'Completed')
        .not('status', 'eq', 'Cancelled')
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((data) => OrderModel.fromJson(data)).toList();
  }

  Future<List<OrderModel>> fetchHistoryOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('orderslist')
        .select()
        .eq('user_id', userId)
        .inFilter('status', ['Completed', 'Cancelled'])
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((data) => OrderModel.fromJson(data)).toList();
  }
}
