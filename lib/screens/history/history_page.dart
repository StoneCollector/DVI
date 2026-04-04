import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/services/order_service.dart';
import 'package:dreamventz/models/order_model.dart';
import 'package:dreamventz/config/supabase_config.dart';
import 'package:dreamventz/models/order_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final orders = await _orderService.fetchHistoryOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load history: $e')),
        );
      }
    }
  }

  String _formatInr(num value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  Color _getStatusColor(String status) {
    if (status == 'Completed') return Colors.green;
    if (status == 'Cancelled') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f3f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfff5f3f8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Order History',
          style: GoogleFonts.urbanist(
            color: const Color(0xff14111e),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff17141f)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.more_vert, color: Color(0xff17141f)),
          SizedBox(width: 14),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Text(
                    'No historical orders.',
                    style: GoogleFonts.urbanist(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return _HistoryCard(order: order);
                    },
                  ),
                ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final OrderModel order;
  const _HistoryCard({required this.order});

  String _formatInr(num value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  Color _getStatusColor(String status) {
    if (status == 'Completed') return Colors.green;
    if (status == 'Cancelled') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff14111e),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed on ${order.createdAt.toLocal().toString().split(' ')[0]}',
                      style: GoogleFonts.urbanist(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xffe8f5e9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatInr(order.totalAmount),
                    style: GoogleFonts.urbanist(
                      color: const Color(0xff2e7d32),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xfff5f3f8)),
          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xfff5f3f8),
                          borderRadius: BorderRadius.circular(8),
                          image: item.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(SupabaseConfig.getImageUrl(item.imageUrl!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: item.imageUrl == null
                            ? const Icon(Icons.category, color: Colors.grey, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              item.itemType == 'venue'
                                  ? '${item.quantity} Guests'
                                  : '${item.hours} Hours',
                              style: GoogleFonts.urbanist(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          // Status Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xfffdfdfd),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  order.status == 'Completed' ? Icons.check_circle : Icons.cancel,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  order.status,
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

