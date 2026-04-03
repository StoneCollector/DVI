import 'package:dreamventz/components/cart_tile.dart';
import 'package:dreamventz/models/cart_item.dart';
import 'package:dreamventz/models/coupon_model.dart';
import 'package:dreamventz/screens/coupons/coupons_page.dart';
import 'package:dreamventz/services/cart_service.dart';
import 'package:dreamventz/services/wishlist_service.dart';
import 'package:dreamventz/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  final int refreshSignal;

  const CartPage({super.key, this.refreshSignal = 0});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();

  bool _isLoading = true;
  String? _errorMessage;
  List<CartDisplayItem> _items = [];
  CouponModel? _selectedCoupon;

  int get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.lineTotal);
  }

  int get _discountAmount {
    if (_selectedCoupon == null) {
      return 0;
    }
    return _selectedCoupon!.calculateDiscount(_subtotal);
  }

  int get _payableAmount {
    final int intValue = _subtotal - _discountAmount;
    return intValue < 0 ? 0 : intValue;
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void didUpdateWidget(covariant CartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSignal != widget.refreshSignal) {
      _loadCart();
    }
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _cartService.fetchCartDisplayItems();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load cart: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openCouponsPage() async {
    final Object? result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CouponsPage(selectedCoupon: _selectedCoupon, subtotal: _subtotal),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result is CouponModel) {
      setState(() {
        _selectedCoupon = result;
      });
      return;
    }

    if (result == false) {
      setState(() {
        _selectedCoupon = null;
      });
    }
  }

  CartDisplayItem _copyItem(CartDisplayItem item, {int? quantity, int? hours}) {
    return CartDisplayItem(
      cartId: item.cartId,
      itemType: item.itemType,
      itemId: item.itemId,
      title: item.title,
      meta: item.meta,
      tag: item.tag,
      imageUrl: item.imageUrl,
      quantity: quantity ?? item.quantity,
      hours: hours ?? item.hours,
      unitPrice: item.unitPrice,
      maxQuantity: item.maxQuantity,
    );
  }

  void _replaceItemLocally(CartDisplayItem updatedItem) {
    setState(() {
      _items = _items
          .map((item) => item.cartId == updatedItem.cartId ? updatedItem : item)
          .toList();
    });
  }

  Future<void> _incrementItem(CartDisplayItem item) async {
    final previousItems = List<CartDisplayItem>.from(_items);

    try {
      if (item.itemType == CartItemType.venue) {
        final nextQuantity = item.quantity + 50;
        final maxQuantity = item.maxQuantity;

        if (maxQuantity != null && nextQuantity > maxQuantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Guest count cannot exceed venue capacity ($maxQuantity).',
              ),
            ),
          );
          return;
        }

        _replaceItemLocally(_copyItem(item, quantity: nextQuantity));

        await _cartService.updateVenueQuantity(
          cartId: item.cartId,
          venueId: item.itemId,
          quantity: nextQuantity,
        );
      } else {
        final nextHours = item.hours + 1;
        if (nextHours > 12) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hours cannot exceed 12.')),
          );
          return;
        }

        _replaceItemLocally(_copyItem(item, hours: nextHours));

        await _cartService.updateVendorHours(
          cartId: item.cartId,
          vendorCardId: item.itemId,
          hours: nextHours,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = previousItems;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update cart item: $e')));
    }
  }

  Future<void> _decrementItem(CartDisplayItem item) async {
    final previousItems = List<CartDisplayItem>.from(_items);

    try {
      if (item.itemType == CartItemType.venue) {
        final nextQuantity = item.quantity - 50;
        if (nextQuantity < 50) {
          return;
        }

        _replaceItemLocally(_copyItem(item, quantity: nextQuantity));

        await _cartService.updateVenueQuantity(
          cartId: item.cartId,
          venueId: item.itemId,
          quantity: nextQuantity,
        );
      } else {
        final nextHours = item.hours - 1;
        if (nextHours < 1) {
          return;
        }

        _replaceItemLocally(_copyItem(item, hours: nextHours));

        await _cartService.updateVendorHours(
          cartId: item.cartId,
          vendorCardId: item.itemId,
          hours: nextHours,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = previousItems;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update cart item: $e')));
    }
  }

  Future<void> _removeItem(CartDisplayItem item) async {
    final previousItems = List<CartDisplayItem>.from(_items);
    setState(() {
      _items = _items.where((entry) => entry.cartId != item.cartId).toList();
    });

    try {
      await _cartService.removeCartItem(item.cartId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = previousItems;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to remove item: $e')));
    }
  }

  Future<void> _saveForLater(CartDisplayItem item) async {
    final previousItems = List<CartDisplayItem>.from(_items);
    setState(() {
      _items = _items.where((entry) => entry.cartId != item.cartId).toList();
    });

    try {
      if (item.itemType == CartItemType.venue) {
        final ids = await _wishlistService.fetchWishlistedVenueIds();
        if (!ids.contains(item.itemId)) {
          await _wishlistService.toggleVenue(item.itemId);
        }
      } else {
        final ids = await _wishlistService.fetchWishlistedVendorCardIds();
        if (!ids.contains(item.itemId)) {
          await _wishlistService.toggleVendorCard(item.itemId);
        }
      }

      await _cartService.removeCartItem(item.cartId);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item saved for later.')));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = previousItems;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save item for later: $e')),
      );
    }
  }

  String _formatInr(int value) {
    final String number = value.toString();
    if (number.length <= 3) {
      return '₹$number';
    }

    final String lastThree = number.substring(number.length - 3);
    String remaining = number.substring(0, number.length - 3);
    final List<String> groups = [];

    while (remaining.length > 2) {
      groups.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      groups.insert(0, remaining);
    }

    return '₹${groups.join(',')},$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xfff5f3f8),
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: const Color(0xfff5f3f8),
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Your Cart',
              style: GoogleFonts.urbanist(
                color: const Color(0xff14111e),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xff17141f)),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.homeRoute,
                  (route) => false,
                );
              },
            ),
            actions: const [
              Icon(Icons.more_vert, color: Color(0xff17141f)),
              SizedBox(width: 14),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: _buildBody()),
              _buildBottomSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadCart, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Text(
          'Your cart is empty.',
          style: GoogleFonts.urbanist(
            fontSize: 18,
            color: const Color(0xff2f2b37),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCouponBanner(),
          const SizedBox(height: 10),
          ..._items.map(
            (item) => CartTile(
              title: item.title,
              meta: item.meta,
              tag: item.tag,
              price: _formatInr(item.lineTotal),
              imageUrl: item.imageUrl,
              quantityLabel: item.displayLabel,
              quantityValue: item.displayCount,
              onIncrement: () => _incrementItem(item),
              onDecrement: () => _decrementItem(item),
              onSaveForLater: () => _saveForLater(item),
              onDelete: () => _removeItem(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponBanner() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _openCouponsPage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xffefeae3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffe3dbcf)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              color: Color(0xff9a7011),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCoupon == null
                        ? 'Apply coupons to save more on your event'
                        : 'Applied coupon: ${_selectedCoupon!.code}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: const Color(0xff23202b),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedCoupon == null
                        ? 'View Offers'
                        : '${_selectedCoupon!.title} • Saved ${_formatInr(_discountAmount)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      color: const Color(0xff1858b6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xff3e3a45), size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: Color(0xfff7f6fa),
        border: Border(top: BorderSide(color: Color(0xffe6e2ee))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Subtotal (${_items.length} items):',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: const Color(0xff2a2733),
                  ),
                ),
              ),
              Text(
                _formatInr(_subtotal),
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: const Color(0xff2a2733),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xff2a2733)),
            ],
          ),
          if (_selectedCoupon != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Coupon (${_selectedCoupon!.code})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      color: const Color(0xff5f586d),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '- ${_formatInr(_discountAmount)}',
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    color: const Color(0xff247344),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _formatInr(_payableAmount),
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: const Color(0xff100d17),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff181510),
                foregroundColor: const Color(0xfff8cf3f),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              onPressed: () {},
              child: Text(
                'Continue to Booking',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
