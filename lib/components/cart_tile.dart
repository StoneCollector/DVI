import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartTile extends StatelessWidget {
  final String title;
  final String? meta;
  final String tag;
  final String price;
  final String? imageUrl;
  final String? quantityLabel;
  final int? quantityValue;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onSaveForLater;
  final VoidCallback? onDelete;

  const CartTile({
    super.key,
    required this.title,
    this.meta,
    required this.tag,
    required this.price,
    this.imageUrl,
    this.quantityLabel,
    this.quantityValue,
    this.onIncrement,
    this.onDecrement,
    this.onSaveForLater,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe8e6ef)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 96,
                  height: 78,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xffe6dfd2), Color(0xfff5f1e8)],
                    ),
                  ),
                  child: (imageUrl ?? '').trim().isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_outlined,
                              color: Color(0xff9f9aa8),
                              size: 34,
                            );
                          },
                        )
                      : const Icon(
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
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.urbanist(
                          color: const Color(0xff16131f),
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if ((meta ?? '').trim().isNotEmpty)
                            TextSpan(text: ' • ${meta!.trim()}'),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
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
                              tag,
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
                          price,
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
                    if (quantityValue != null &&
                        quantityLabel != null &&
                        onIncrement != null &&
                        onDecrement != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            quantityLabel!,
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: const Color(0xff4a4752),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          _StepperButton(
                            icon: Icons.remove,
                            onTap: onDecrement!,
                          ),
                          Container(
                            width: 36,
                            alignment: Alignment.center,
                            child: Text(
                              '$quantityValue',
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                color: const Color(0xff12101a),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _StepperButton(icon: Icons.add, onTap: onIncrement!),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xfff8f7fa),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffece9f3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onSaveForLater,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          color: Color(0xff63606c),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Save for later',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: const Color(0xff2f2b36),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 18, color: const Color(0xffd8d2e0)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        color: Color(0xff63606c),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Delete',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: const Color(0xff2f2b36),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xfff1eff6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xffddd8e7)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xff3e3948)),
      ),
    );
  }
}
