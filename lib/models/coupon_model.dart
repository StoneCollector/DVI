enum CouponDiscountType { percent, flat }

class CouponModel {
  final String id;
  final String code;
  final String title;
  final String subtitle;
  final String highlightLine;
  final String termsLine;
  final CouponDiscountType discountType;
  final int discountValue;
  final int minOrder;
  final int? maxDiscount;

  const CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.highlightLine,
    required this.termsLine,
    required this.discountType,
    required this.discountValue,
    required this.minOrder,
    this.maxDiscount,
  });

  bool isEligible(int subtotal) {
    return subtotal >= minOrder;
  }

  int calculateDiscount(int subtotal) {
    if (!isEligible(subtotal)) {
      return 0;
    }

    if (discountType == CouponDiscountType.flat) {
      return discountValue;
    }

    final int computed = ((subtotal * discountValue) / 100).floor();
    if (maxDiscount == null) {
      return computed;
    }
    return computed > maxDiscount! ? maxDiscount! : computed;
  }
}
