import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/sort.dart';
import 'package:dreamventz/components/vendor_tile.dart';
import 'package:dreamventz/models/vendor_card.dart';
import 'package:dreamventz/services/vendor_card_service.dart';
import 'package:dreamventz/services/wishlist_service.dart';
import 'package:dreamventz/screens/vendors/vendor_profile_page.dart';

class VendorListPage extends StatefulWidget {
  final String categoryName;
  final int categoryId;

  const VendorListPage({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<VendorListPage> createState() => _VendorListPageState();
}

class _VendorListPageState extends State<VendorListPage> {
  static const double _budgetStep = 5000;
  static const double _fixedMaxBudget = 50000;

  // Data from Supabase
  List<VendorCard> allVendorCards = [];
  List<VendorCard> filteredVendorCards = [];
  bool isLoading = true;
  String? errorMessage;

  // Filter states
  String sortBy = 'Rating';
  String selectedCity = 'All';
  double selectedMinBudget = 0;
  double selectedMaxBudget = 0;
  double categoryMaxBudget = 0;
  bool hasBudgetData = false;

  // Service tags filter
  List<String> selectedServiceTags = [];
  List<String> availableServiceTags = [];

  // Quality tags filter
  List<String> selectedQualityTags = [];
  List<String> availableQualityTags = [];

  List<String> availableCities = [];
  final WishlistService _wishlistService = WishlistService();
  Set<String> wishlistedVendorCardIds = <String>{};
  Set<String> wishlistBusyVendorCardIds = <String>{};

  bool get _isBudgetFilterActive {
    return hasBudgetData &&
        (selectedMinBudget > 0 || selectedMaxBudget < categoryMaxBudget);
  }

  double _effectivePrice(VendorCard card) {
    if (card.discountedPrice > 0) return card.discountedPrice;
    if (card.originalPrice > 0) return card.originalPrice;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _loadVendorCards();
  }

  Future<void> _loadVendorCards() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final service = VendorCardService();

      // Fetch vendor cards
      allVendorCards = await service.getVendorCardsByCategory(
        widget.categoryId,
      );

      // Fetch cities and tags
      availableCities = await service.getUniqueCities(widget.categoryId);
      availableServiceTags = await service.getAllServiceTags(widget.categoryId);
      availableQualityTags = await service.getAllQualityTags(widget.categoryId);
      Set<String> loadedWishlistIds = <String>{};

      try {
        loadedWishlistIds = await _wishlistService
            .fetchWishlistedVendorCardIds();
      } catch (_) {
        loadedWishlistIds = <String>{};
      }

      final rawMaxPrice = allVendorCards.isEmpty
          ? 0.0
          : allVendorCards.map(_effectivePrice).reduce((a, b) => a > b ? a : b);

      final maxPrice = _fixedMaxBudget;

      setState(() {
        categoryMaxBudget = maxPrice;
        hasBudgetData = rawMaxPrice > 0;
        selectedMinBudget = 0;
        selectedMaxBudget = maxPrice;
        wishlistedVendorCardIds = loadedWishlistIds;
        filteredVendorCards = List.from(allVendorCards);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load vendors: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _toggleVendorWishlist(VendorCard card) async {
    if (wishlistBusyVendorCardIds.contains(card.id)) return;

    final isCurrentlyWishlisted = wishlistedVendorCardIds.contains(card.id);
    setState(() {
      wishlistBusyVendorCardIds = {...wishlistBusyVendorCardIds, card.id};
      if (isCurrentlyWishlisted) {
        wishlistedVendorCardIds = {...wishlistedVendorCardIds}..remove(card.id);
      } else {
        wishlistedVendorCardIds = {...wishlistedVendorCardIds, card.id};
      }
    });

    try {
      final nowWishlisted = await _wishlistService.toggleVendorCard(card.id);
      if (!mounted) return;

      setState(() {
        final updated = {...wishlistedVendorCardIds};
        if (nowWishlisted) {
          updated.add(card.id);
        } else {
          updated.remove(card.id);
        }
        wishlistedVendorCardIds = updated;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (isCurrentlyWishlisted) {
          wishlistedVendorCardIds = {...wishlistedVendorCardIds, card.id};
        } else {
          wishlistedVendorCardIds = {...wishlistedVendorCardIds}
            ..remove(card.id);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update wishlist: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        wishlistBusyVendorCardIds = {...wishlistBusyVendorCardIds}
          ..remove(card.id);
      });
    }
  }

  void _applyFilters() {
    setState(() {
      filteredVendorCards = List.from(allVendorCards);

      // City filter
      if (selectedCity != 'All') {
        filteredVendorCards = filteredVendorCards
            .where((card) => card.city == selectedCity)
            .toList();
      }

      // Service tags filter
      if (selectedServiceTags.isNotEmpty) {
        filteredVendorCards = filteredVendorCards.where((card) {
          // Check if ALL selected service tags are present (AND logic)
          return selectedServiceTags.every(
            (selectedTag) => card.serviceTags.contains(selectedTag),
          );
        }).toList();
      }

      // Quality tags filter
      if (selectedQualityTags.isNotEmpty) {
        filteredVendorCards = filteredVendorCards.where((card) {
          // Check if ALL selected quality tags are present (AND logic)
          return selectedQualityTags.every(
            (selectedTag) => card.qualityTags.contains(selectedTag),
          );
        }).toList();
      }

      // Budget filter (range slider)
      if (_isBudgetFilterActive) {
        filteredVendorCards = filteredVendorCards
            .where(
              (card) =>
                  _effectivePrice(card) >= selectedMinBudget &&
                  _effectivePrice(card) <= selectedMaxBudget,
            )
            .toList();
      }

      // Sort
      if (sortBy == 'Price: Low to High') {
        filteredVendorCards.sort(
          (a, b) => a.discountedPrice.compareTo(b.discountedPrice),
        );
      } else if (sortBy == 'Price: High to Low') {
        filteredVendorCards.sort(
          (a, b) => b.discountedPrice.compareTo(a.discountedPrice),
        );
      } else if (sortBy == 'Discount') {
        filteredVendorCards.sort(
          (a, b) => b.discountPercent.compareTo(a.discountPercent),
        );
      }
    });
  }

  Future<void> _showCityMenu(TapDownDetails details) async {
    final selected = await _showRoundedMenu<String>(details, [
      const PopupMenuItem(value: 'All', child: Text('All')),
      ...availableCities.map(
        (city) => PopupMenuItem(value: city, child: Text(city)),
      ),
    ]);

    if (selected == null) return;
    setState(() {
      selectedCity = selected;
    });
    _applyFilters();
  }

  Future<void> _showServiceTagsMenu(TapDownDetails details) async {
    List<String> tempSelectedTags = List.from(selectedServiceTags);

    await _showAnchoredDropdown(
      details: details,
      width: 300,
      child: StatefulBuilder(
        builder: (context, setMenuState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Text(
                  'Service Types',
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff0c1c2c),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: availableServiceTags.map((tag) {
                      return CheckboxListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          tag,
                          style: GoogleFonts.urbanist(
                            color: const Color(0xff0c1c2c),
                            fontSize: 13,
                          ),
                        ),
                        value: tempSelectedTags.contains(tag),
                        activeColor: const Color(0xff0c1c2c),
                        onChanged: (value) {
                          setMenuState(() {
                            if (value == true) {
                              tempSelectedTags.add(tag);
                            } else {
                              tempSelectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.urbanist(color: Colors.grey[600]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedServiceTags = tempSelectedTags;
                        });
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      child: Text(
                        'Apply',
                        style: GoogleFonts.urbanist(
                          color: const Color(0xff0c1c2c),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showQualityTagsMenu(TapDownDetails details) async {
    List<String> tempSelectedTags = List.from(selectedQualityTags);

    await _showAnchoredDropdown(
      details: details,
      width: 300,
      child: StatefulBuilder(
        builder: (context, setMenuState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Text(
                  'Quality Tags',
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff0c1c2c),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: availableQualityTags.map((tag) {
                      return CheckboxListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          tag,
                          style: GoogleFonts.urbanist(
                            color: const Color(0xff0c1c2c),
                            fontSize: 13,
                          ),
                        ),
                        value: tempSelectedTags.contains(tag),
                        activeColor: const Color(0xff0c1c2c),
                        onChanged: (value) {
                          setMenuState(() {
                            if (value == true) {
                              tempSelectedTags.add(tag);
                            } else {
                              tempSelectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.urbanist(color: Colors.grey[600]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedQualityTags = tempSelectedTags;
                        });
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      child: Text(
                        'Apply',
                        style: GoogleFonts.urbanist(
                          color: const Color(0xff0c1c2c),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showBudgetMenu(TapDownDetails details) async {
    final maxSliderValue = categoryMaxBudget > 0
        ? categoryMaxBudget
        : _budgetStep;

    double tempMin = selectedMinBudget.clamp(0, maxSliderValue);
    double tempMax = selectedMaxBudget > 0
        ? selectedMaxBudget.clamp(0, maxSliderValue)
        : maxSliderValue;

    if (tempMax <= tempMin) {
      tempMin = 0;
      tempMax = maxSliderValue;
    }

    RangeValues tempValues = RangeValues(tempMin, tempMax);

    await _showAnchoredDropdown(
      details: details,
      width: 320,
      child: StatefulBuilder(
        builder: (context, setMenuState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Text(
                  'Budget Range',
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff0c1c2c),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '₹${tempValues.start.toInt()} - ₹${tempValues.end.toInt()}',
                  style: GoogleFonts.urbanist(
                    color: const Color(0xff0c1c2c),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: RangeSlider(
                  values: tempValues,
                  min: 0,
                  max: maxSliderValue,
                  divisions: (maxSliderValue / _budgetStep).round(),
                  labels: RangeLabels(
                    '₹${tempValues.start.toInt()}',
                    '₹${tempValues.end.toInt()}',
                  ),
                  activeColor: const Color(0xff0c1c2c),
                  inactiveColor: Colors.grey[300],
                  onChanged: (values) {
                    final snappedStart =
                        ((values.start / _budgetStep).round() * _budgetStep)
                            .clamp(0.0, maxSliderValue);
                    final snappedEnd =
                        ((values.end / _budgetStep).round() * _budgetStep)
                            .clamp(0.0, maxSliderValue);

                    setMenuState(() {
                      if (snappedStart <= snappedEnd) {
                        tempValues = RangeValues(snappedStart, snappedEnd);
                      } else {
                        tempValues = RangeValues(snappedEnd, snappedStart);
                      }
                    });
                  },
                ),
              ),
              if (!hasBudgetData)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'No budget data available for this category.',
                    style: GoogleFonts.urbanist(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.urbanist(color: Colors.grey[600]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedMinBudget = tempValues.start;
                          selectedMaxBudget = tempValues.end;
                        });
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      child: Text(
                        'Apply',
                        style: GoogleFonts.urbanist(
                          color: const Color(0xff0c1c2c),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAnchoredDropdown({
    required TapDownDetails details,
    required Widget child,
    double width = 280,
  }) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = details.globalPosition;
    final left = (position.dx - 20).clamp(8.0, overlay.size.width - width - 8);
    final top = position.dy + 8;

    return showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Dismiss',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, menuChild) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * -8),
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: value,
                          child: menuChild,
                        ),
                      ),
                    ),
                  );
                },
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<T?> _showRoundedMenu<T>(
    TapDownDetails details,
    List<PopupMenuEntry<T>> items,
  ) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = details.globalPosition;

    return showMenu<T>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 8,
      color: Colors.white,
      items: items,
    );
  }

  void _showServiceTagsDialog() {
    // Create a local copy of selected tags for the dialog
    List<String> tempSelectedTags = List.from(selectedServiceTags);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Service Types',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                color: Color(0xff0c1c2c),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: availableServiceTags.map((tag) {
                  return CheckboxListTile(
                    title: Text(
                      tag,
                      style: GoogleFonts.urbanist(color: Color(0xff0c1c2c)),
                    ),
                    value: tempSelectedTags.contains(tag),
                    activeColor: Color(0xff0c1c2c),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          tempSelectedTags.add(tag);
                        } else {
                          tempSelectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.urbanist(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedServiceTags = tempSelectedTags;
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
                child: Text(
                  'OK',
                  style: GoogleFonts.urbanist(
                    color: Color(0xff0c1c2c),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBudgetDialog() {
    final maxSliderValue = categoryMaxBudget > 0
        ? categoryMaxBudget
        : _budgetStep;

    double tempMin = selectedMinBudget.clamp(0, maxSliderValue);
    double tempMax = selectedMaxBudget > 0
        ? selectedMaxBudget.clamp(0, maxSliderValue)
        : maxSliderValue;

    // Keep two visible thumbs with a valid range similar to e-commerce sliders.
    if (tempMax <= tempMin) {
      tempMin = 0;
      tempMax = maxSliderValue;
    }

    RangeValues tempValues = RangeValues(tempMin, tempMax);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Budget Range',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                color: Color(0xff0c1c2c),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${tempValues.start.toInt()} - ₹${tempValues.end.toInt()}',
                  style: GoogleFonts.urbanist(
                    color: Color(0xff0c1c2c),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                RangeSlider(
                  values: tempValues,
                  min: 0,
                  max: maxSliderValue,
                  divisions: (maxSliderValue / _budgetStep).round(),
                  labels: RangeLabels(
                    '₹${tempValues.start.toInt()}',
                    '₹${tempValues.end.toInt()}',
                  ),
                  activeColor: const Color(0xff0c1c2c),
                  inactiveColor: Colors.grey[300],
                  onChanged: (values) {
                    final snappedStart =
                        ((values.start / _budgetStep).round() * _budgetStep)
                            .clamp(0.0, maxSliderValue);
                    final snappedEnd =
                        ((values.end / _budgetStep).round() * _budgetStep)
                            .clamp(0.0, maxSliderValue);

                    setDialogState(() {
                      if (snappedStart <= snappedEnd) {
                        tempValues = RangeValues(snappedStart, snappedEnd);
                      } else {
                        tempValues = RangeValues(snappedEnd, snappedStart);
                      }
                    });
                  },
                ),
                if (!hasBudgetData)
                  Text(
                    'No budget data available for this category.',
                    style: GoogleFonts.urbanist(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.urbanist(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedMinBudget = tempValues.start;
                    selectedMaxBudget = tempValues.end;
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
                child: Text(
                  'Apply',
                  style: GoogleFonts.urbanist(
                    color: Color(0xff0c1c2c),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showQualityTagsDialog() {
    // Create a local copy of selected tags for the dialog
    List<String> tempSelectedTags = List.from(selectedQualityTags);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Quality Tags',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                color: Color(0xff0c1c2c),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: availableQualityTags.map((tag) {
                  return CheckboxListTile(
                    title: Text(
                      tag,
                      style: GoogleFonts.urbanist(color: Color(0xff0c1c2c)),
                    ),
                    value: tempSelectedTags.contains(tag),
                    activeColor: Color(0xff0c1c2c),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          tempSelectedTags.add(tag);
                        } else {
                          tempSelectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.urbanist(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedQualityTags = tempSelectedTags;
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
                child: Text(
                  'OK',
                  style: GoogleFonts.urbanist(
                    color: Color(0xff0c1c2c),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Select City',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            color: Color(0xff0c1c2c),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCityOption('All'),
              ...availableCities.map((city) => _buildCityOption(city)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityOption(String option) {
    return RadioListTile<String>(
      title: Text(
        option,
        style: GoogleFonts.urbanist(color: Color(0xff0c1c2c)),
      ),
      value: option,
      groupValue: selectedCity,
      activeColor: Color(0xff0c1c2c),
      onChanged: (value) {
        setState(() {
          selectedCity = value!;
        });
        Navigator.pop(context);
        _applyFilters();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xff0c1c2c),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xff0c1c2c)))
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text(
                    'Error loading vendors',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadVendorCards,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff0c1c2c),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.urbanist(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Filter chips
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SortComponent(
                          selectedValue: sortBy,
                          options: const [
                            'Price: Low to High',
                            'Price: High to Low',
                            'Discount',
                          ],
                          onChanged: (value) {
                            setState(() {
                              sortBy = value;
                            });
                            _applyFilters();
                          },
                          labelTextStyle: GoogleFonts.urbanist(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          inactiveBorderColor: Colors.grey[300]!,
                          inactiveTextColor: Colors.grey[800]!,
                          inactiveIconColor: Colors.grey[700]!,
                        ),
                        SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'City',
                          icon: Icons.location_city,
                          onTap: _showCityDialog,
                          onTapDown: _showCityMenu,
                        ),
                        SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Services',
                          icon: Icons.camera_alt,
                          isSelected: selectedServiceTags.isNotEmpty,
                          onTap: _showServiceTagsDialog,
                          onTapDown: _showServiceTagsMenu,
                        ),
                        SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Quality',
                          icon: Icons.verified,
                          isSelected: selectedQualityTags.isNotEmpty,
                          onTap: _showQualityTagsDialog,
                          onTapDown: _showQualityTagsMenu,
                        ),
                        SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Budget',
                          icon: Icons.currency_rupee,
                          isSelected: _isBudgetFilterActive,
                          onTap: _showBudgetDialog,
                          onTapDown: _showBudgetMenu,
                        ),
                      ],
                    ),
                  ),
                ),

                // Results count
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                    top: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${filteredVendorCards.length} vendors found',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Vendor list
                Expanded(
                  child: filteredVendorCards.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No vendors found',
                                style: GoogleFonts.urbanist(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters',
                                style: GoogleFonts.urbanist(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(top: 8, bottom: 16),
                          itemCount: filteredVendorCards.length,
                          itemBuilder: (context, index) {
                            final card = filteredVendorCards[index];
                            return VendorTile(
                              studioName: card.studioName,
                              serviceType: card.serviceTags.isNotEmpty
                                  ? card.serviceTags.first
                                  : '',
                              rating:
                                  4.5, // Default since we don't have rating in vendor_cards yet
                              reviewCount: 0, // Default
                              startingPrice: card.formattedDiscountedPrice,
                              originalPrice: card.formattedOriginalPrice,
                              discountPercent: card.discountPercent,
                              imageFileName: card.imagePath,
                              location: card.city,
                              serviceTags: card.serviceTags,
                              qualityTags: card.qualityTags,
                              isWishlisted: wishlistedVendorCardIds.contains(
                                card.id,
                              ),
                              isWishlistBusy: wishlistBusyVendorCardIds
                                  .contains(card.id),
                              onWishlistTap: () => _toggleVendorWishlist(card),
                              onViewProfile: () {
                                // Convert VendorCard to Map format for VendorProfilePage
                                final vendorData = {
                                  'id': card.id,
                                  'studio_name': card.studioName,
                                  'city': card.city,
                                  'image_path': card.imagePath,
                                  'service_tags': card.serviceTags,
                                  'quality_tags': card.qualityTags,
                                  'original_price': card.originalPrice,
                                  'discounted_price': card.discountedPrice,
                                  'rating': 4.5,
                                  'reviewCount': 0,
                                };

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VendorProfilePage(
                                      vendorData: vendorData,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    bool isSelected = false,
    required VoidCallback onTap,
    void Function(TapDownDetails details)? onTapDown,
  }) {
    return GestureDetector(
      onTap: onTapDown == null ? onTap : null,
      onTapDown: onTapDown,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff0c1c2c) : Colors.white,
          border: Border.all(
            color: isSelected ? Color(0xff0c1c2c) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }
}
