import 'package:dreamventz/components/cart_tile.dart';
import 'package:dreamventz/models/coupon_model.dart';
import 'package:dreamventz/screens/coupons/coupons_page.dart';
import 'package:dreamventz/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const int _baseSubtotal = 220000;

  int _guestCount = 300;
  int _hoursCount = 6;
  CouponModel? _selectedCoupon;

  int get _discountAmount {
    if (_selectedCoupon == null) {
      return 0;
    }
    return _selectedCoupon!.calculateDiscount(_baseSubtotal);
  }

  int get _payableAmount {
    final int intValue = _baseSubtotal - _discountAmount;
    return intValue < 0 ? 0 : intValue;
  }

  Future<void> _openCouponsPage() async {
    final Object? result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (context) => CouponsPage(
          selectedCoupon: _selectedCoupon,
          subtotal: _baseSubtotal,
        ),
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

    // false is a dedicated signal from CouponsPage for explicit unapply.
    if (result == false) {
      setState(() {
        _selectedCoupon = null;
      });
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCouponBanner(),
                      const SizedBox(height: 10),
                      CartTile(
                        title: 'Elegant Palace Banquet Hall',
                        tag: 'Limited Time Deal',
                        quantityLabel: 'Guests',
                        quantityValue: _guestCount,
                        onDecrement: () {
                          if (_guestCount > 50) {
                            setState(() {
                              _guestCount -= 50;
                            });
                          }
                        },
                        onIncrement: () {
                          setState(() {
                            _guestCount += 50;
                          });
                        },
                        price: '₹1,75,000',
                      ),
                      CartTile(
                        title: 'Royal Lens Photography',
                        tag: 'Free Pre-Wedding Shoot',
                        quantityLabel: 'Hours',
                        quantityValue: _hoursCount,
                        onDecrement: () {
                          if (_hoursCount > 1) {
                            setState(() {
                              _hoursCount -= 1;
                            });
                          }
                        },
                        onIncrement: () {
                          setState(() {
                            _hoursCount += 1;
                          });
                        },
                        price: '₹45,000',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 8),
                        child: Text(
                          'More Suggested Services/Venues',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.urbanist(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xff16131f),
                          ),
                        ),
                      ),
                      _buildSuggestionTile(),
                    ],
                  ),
                ),
              ),
              _buildBottomSummary(),
            ],
          ),
        ),
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

  Widget _buildSuggestionTile() {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe8e5ef)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 98,
                  height: 82,
                  color: const Color(0xffece5d9),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xff9f9aa8),
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: GoogleFonts.urbanist(
                                color: const Color(0xff16131f),
                                fontSize: 14,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Dream Palace Lawn',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(text: ''),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.favorite_border,
                          color: Color(0xff6a6573),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Picturesque garden venue',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: const Color(0xff2e2b36),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xfff6de8a),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Limited Time Deal',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.urbanist(
                                fontSize: 10,
                                color: const Color(0xff6f5410),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹1,40,000',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.urbanist(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xff12101a),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2a62bc),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: Text(
                    'View Details',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Offer: Save extra 10%',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  color: const Color(0xff2f2b37),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
                  'Subtotal (2 items):',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: const Color(0xff2a2733),
                  ),
                ),
              ),
              Text(
                _formatInr(_baseSubtotal),
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
