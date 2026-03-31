import 'package:dreamventz/models/coupon_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CouponTile extends StatelessWidget {
  final CouponModel coupon;
  final int subtotal;
  final bool isSelected;
  final VoidCallback onApply;

  const CouponTile({
    super.key,
    required this.coupon,
    required this.subtotal,
    required this.isSelected,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final bool eligible = coupon.isEligible(subtotal);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffddd8e7)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: eligible
                          ? const Color(0xffc9c3d7)
                          : const Color(0xffe4e1eb),
                    ),
                    color: eligible
                        ? const Color(0xfffaf9fd)
                        : const Color(0xfff5f4f8),
                  ),
                  child: Text(
                    coupon.code,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: eligible
                          ? const Color(0xff7f788f)
                          : const Color(0xffb5b0bf),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: (eligible || isSelected) ? onApply : null,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isSelected ? 'UNAPPLY' : 'APPLY',
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: (eligible || isSelected)
                          ? const Color(0xffdd2c68)
                          : const Color(0xffcdc7d8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                coupon.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  color: eligible
                      ? const Color(0xff464052)
                      : const Color(0xffb7b1c2),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                coupon.highlightLine,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  color: const Color(0xffd44378),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(height: 1, color: const Color(0xffece8f3)),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                coupon.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  color: const Color(0xff857f91),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                coupon.termsLine,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: const Color(0xff484252),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
