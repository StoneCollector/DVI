import 'package:dreamventz/components/coupon_tile.dart';
import 'package:dreamventz/models/coupon_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CouponsPage extends StatefulWidget {
  final CouponModel? selectedCoupon;
  final int subtotal;

  const CouponsPage({super.key, this.selectedCoupon, required this.subtotal});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  final TextEditingController _controller = TextEditingController();
  final List<CouponModel> _coupons = const [
    CouponModel(
      id: '1',
      code: 'ZEPT0100',
      title: 'Flat 10% off upto ₹4500',
      subtitle: 'Get Flat 10% off upto ₹4500 off on order above ₹25000',
      highlightLine: 'Add products worth ₹25000 to qualify for this deal.',
      termsLine: '+ MORE',
      discountType: CouponDiscountType.percent,
      discountValue: 10,
      minOrder: 25000,
      maxDiscount: 4500,
    ),
    CouponModel(
      id: '2',
      code: 'ZEPTKACC',
      title: 'Get 12% off upto ₹200',
      subtitle:
          'Get 12% off upto ₹200 on orders above ₹999 with select Kotak Credit Cards',
      highlightLine:
          'Offer applicable on total payable amount above ₹999 (exclusive of any Zepto cash applied)',
      termsLine: '+ MORE',
      discountType: CouponDiscountType.percent,
      discountValue: 12,
      minOrder: 999,
      maxDiscount: 200,
    ),
    CouponModel(
      id: '3',
      code: 'WEDDING50',
      title: 'Flat ₹2500 off',
      subtitle: 'Flat ₹2500 off on order above ₹50000',
      highlightLine: 'Add products worth ₹50000 to qualify for this deal.',
      termsLine: '+ MORE',
      discountType: CouponDiscountType.flat,
      discountValue: 2500,
      minOrder: 50000,
    ),
    CouponModel(
      id: '4',
      code: 'EVENTS20',
      title: 'Get 15% off upto ₹3000',
      subtitle: 'Get 15% off upto ₹3000 on order above ₹20000',
      highlightLine: 'Add products worth ₹20000 to qualify for this deal.',
      termsLine: '+ MORE',
      discountType: CouponDiscountType.percent,
      discountValue: 15,
      minOrder: 20000,
      maxDiscount: 3000,
    ),
  ];

  String _query = '';

  List<CouponModel> get _filteredCoupons {
    if (_query.isEmpty) {
      return _coupons;
    }
    return _coupons
        .where((coupon) => coupon.code.toUpperCase().contains(_query))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final String sanitized = value.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    final String normalized = sanitized.length > 8
        ? sanitized.substring(0, 8)
        : sanitized;

    if (_controller.text != normalized) {
      _controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    setState(() {
      _query = normalized;
    });
  }

  void _applySearchCoupon() {
    if (_query.length != 8) {
      _showMessage('Enter an 8-character coupon code.');
      return;
    }

    final CouponModel? exactMatch = _coupons.cast<CouponModel?>().firstWhere(
      (coupon) => coupon!.code.toUpperCase() == _query,
      orElse: () => null,
    );

    if (exactMatch == null) {
      _showMessage('Coupon not found.');
      return;
    }

    if (!exactMatch.isEligible(widget.subtotal)) {
      _showMessage('Cart subtotal does not meet this coupon requirement.');
      return;
    }

    Navigator.pop(context, exactMatch);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f3f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfff5f3f8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff1f1c27)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Apply Coupon',
          style: GoogleFonts.urbanist(
            color: const Color(0xff18151f),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xffdfdbe8)),
                      ),
                      child: TextField(
                        controller: _controller,
                        onChanged: _onSearchChanged,
                        textCapitalization: TextCapitalization.characters,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff2a2633),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Coupon Code',
                          hintStyle: GoogleFonts.urbanist(
                            fontSize: 14,
                            color: const Color(0xff9b96a8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: _applySearchCoupon,
                    child: Text(
                      'APPLY',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffdd2c68),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Available Coupons',
                  style: GoogleFonts.urbanist(
                    color: const Color(0xff1f1b28),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (_filteredCoupons.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No coupons found for this code.',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff7e778c),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                  itemCount: _filteredCoupons.length,
                  itemBuilder: (context, index) {
                    final coupon = _filteredCoupons[index];
                    final bool isSelected =
                        widget.selectedCoupon?.id == coupon.id;
                    return CouponTile(
                      coupon: coupon,
                      subtotal: widget.subtotal,
                      isSelected: isSelected,
                      onApply: () {
                        if (isSelected) {
                          Navigator.pop(context, false);
                          return;
                        }

                        if (!coupon.isEligible(widget.subtotal)) {
                          _showMessage(
                            'Cart subtotal does not meet this coupon requirement.',
                          );
                          return;
                        }
                        Navigator.pop(context, coupon);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
