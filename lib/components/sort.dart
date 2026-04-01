import 'package:flutter/material.dart';

/// Reusable sort chip with anchored popup menu selection.
class SortComponent extends StatelessWidget {
  const SortComponent({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.label = 'Sort',
    this.icon = Icons.sort,
    this.isSelected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.borderRadius = 20,
    this.iconSize = 16,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w600,
    this.showDropdownIcon = true,
    this.activeColor = const Color(0xFF0C1C2C),
    this.inactiveBackgroundColor = Colors.white,
    this.inactiveBorderColor = const Color(0xFFE0E0E0),
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = const Color(0xFF424242),
    this.activeIconColor = Colors.white,
    this.inactiveIconColor = const Color(0xFF616161),
    this.menuBackgroundColor = Colors.white,
    this.menuBorderRadius = 14,
    this.menuElevation = 8,
    this.labelTextStyle,
    this.menuItemTextStyle,
  });

  final String selectedValue;
  final List<String> options;
  final ValueChanged<String> onChanged;

  final String label;
  final IconData icon;
  final bool isSelected;

  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showDropdownIcon;

  final Color activeColor;
  final Color inactiveBackgroundColor;
  final Color inactiveBorderColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final Color activeIconColor;
  final Color inactiveIconColor;

  final Color menuBackgroundColor;
  final double menuBorderRadius;
  final double menuElevation;
  final TextStyle? labelTextStyle;
  final TextStyle? menuItemTextStyle;

  Future<void> _showSortMenu(
    BuildContext context,
    TapDownDetails details,
  ) async {
    if (options.isEmpty) return;

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = details.globalPosition;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      initialValue: selectedValue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(menuBorderRadius),
      ),
      elevation: menuElevation,
      color: menuBackgroundColor,
      items: options
          .map(
            (option) => PopupMenuItem<String>(
              value: option,
              child: Text(option, style: menuItemTextStyle),
            ),
          )
          .toList(),
    );

    if (selected == null || selected == selectedValue) return;
    onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final chipBackground = isSelected ? activeColor : inactiveBackgroundColor;
    final chipBorder = isSelected ? activeColor : inactiveBorderColor;
    final chipTextColor = isSelected ? activeTextColor : inactiveTextColor;
    final chipIconColor = isSelected ? activeIconColor : inactiveIconColor;
    final effectiveLabelStyle = (labelTextStyle ?? const TextStyle()).copyWith(
      fontSize: labelTextStyle?.fontSize ?? fontSize,
      fontWeight: labelTextStyle?.fontWeight ?? fontWeight,
      color: chipTextColor,
    );

    return GestureDetector(
      onTapDown: (details) => _showSortMenu(context, details),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: chipBackground,
          border: Border.all(color: chipBorder),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: chipIconColor),
            SizedBox(width: showDropdownIcon ? 6 : 4),
            Text(label, style: effectiveLabelStyle),
            if (showDropdownIcon) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: iconSize,
                color: chipIconColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
