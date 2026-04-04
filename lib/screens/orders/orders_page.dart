import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/models/order_model.dart';
import 'package:dreamventz/services/order_service.dart';
import 'package:dreamventz/config/supabase_config.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _orderService.fetchActiveOrders();
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
          SnackBar(content: Text('Failed to load orders: $e')),
        );
      }
    }
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
          'My Orders',
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
                    'No active orders right now.',
                    style: GoogleFonts.urbanist(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      return _OrderCard(order: _orders[index]);
                    },
                  ),
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  static const List<String> _statuses = [
    'Payment Received',
    'Processing',
    'Confirmed',
    'Scheduled'
  ];

  int _getCurrentStep() {
    final mapping = {
      'Payment Received': 0,
      'Processing': 1,
      'Confirmed': 2,
      'Scheduled': 3,
      'Completed': 4 // Will filter out normally
    };
    return mapping[order.status] ?? 0;
  }

  String _formatInr(num value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final step = _getCurrentStep();

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
          // Progression Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xfffdfdfd),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Status',
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                _AnimatedProgressBar(currentStep: step, steps: _statuses),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const _AnimatedProgressBar({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // Background line
            Container(
              margin: const EdgeInsets.only(top: 14),
              height: 4,
              color: const Color(0xffeeeeee),
            ),
            // Progress line (AnimatedWidth would be nice, using simple proportion here)
            LayoutBuilder(
              builder: (context, constraints) {
                final double segmentWidth = constraints.maxWidth / (steps.length - 1);
                // currentStep dynamically controls the full colored width
                final double activeWidth = currentStep == 0 ? 0 : segmentWidth * currentStep;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(top: 14),
                  height: 4,
                  width: activeWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xff2196f3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(steps.length, (index) {
                final isActive = index <= currentStep;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xff2196f3) : Colors.white,
                    border: Border.all(
                      color: isActive ? const Color(0xff2196f3) : const Color(0xffeeeeee),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: isActive
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Container(),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final isActive = index <= currentStep;
            return SizedBox(
              width: 50,
              child: Text(
                steps[index],
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 10,
                  color: isActive ? const Color(0xff2196f3) : Colors.grey[400],
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
