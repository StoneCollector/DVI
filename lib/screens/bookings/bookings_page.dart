import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/history_tile.dart';
import 'package:dreamventz/config/supabase_config.dart';
import 'package:dreamventz/models/order_model.dart';
import 'package:dreamventz/services/order_service.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingVenueItem {
  final OrderModel order;
  final OrderItem item;

  const _BookingVenueItem({required this.order, required this.item});
}

class _BookingsPageState extends State<BookingsPage> {
  final OrderService _orderService = OrderService();

  List<_BookingVenueItem> _bookingItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final orders = await _orderService.fetchActiveOrders();

      final venueItems = <_BookingVenueItem>[];
      for (final order in orders) {
        for (final item in order.items) {
          if (item.itemType == 'venue') {
            venueItems.add(_BookingVenueItem(order: order, item: item));
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _bookingItems = venueItems;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load bookings: $e')));
    }
  }

  String _formatInr(num value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  String _formatPlacedDate(DateTime createdAt) {
    final date = createdAt.toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return 'Placed on $day/$month/$year';
  }

  String? _resolveOrderItemImageUrl(String? rawUrlOrPath) {
    if (rawUrlOrPath == null || rawUrlOrPath.isEmpty) return null;
    return SupabaseConfig.getImageUrl(rawUrlOrPath);
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
          'My Bookings',
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookingItems.isEmpty
          ? Center(
              child: Text(
                'No venue bookings right now.',
                style: GoogleFonts.urbanist(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount: _bookingItems.length,
                itemBuilder: (context, index) {
                  final booking = _bookingItems[index];
                  return HistoryTile(
                    title: booking.item.title,
                    time: _formatPlacedDate(booking.order.createdAt),
                    price: _formatInr(booking.item.unitPrice),
                    status: 'Pending',
                    statusColor: const Color(0xfff57c00),
                    imageUrl: _resolveOrderItemImageUrl(booking.item.imageUrl),
                  );
                },
              ),
            ),
    );
  }
}
