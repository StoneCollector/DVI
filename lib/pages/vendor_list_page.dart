import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/vendor_tile.dart';
import 'package:dreamventz/models/vendor_card.dart';
import 'package:dreamventz/services/vendor_card_service.dart';
import 'package:dreamventz/pages/vendor_profile_page.dart';

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

  // Data from Supabase
  List<VendorCard> allVendorCards = [];
  List<VendorCard> filteredVendorCards = [];
  bool isLoading = true;
  String? errorMessage;

  // Filter states
  String sortBy = 'Rating';
  String budgetRange = 'All';
  String selectedCity = 'All';
  
  // Service tags filter
  List<String> selectedServiceTags = [];
  List<String> availableServiceTags = [];
  
  // Quality tags filter
  List<String> selectedQualityTags = [];
  List<String> availableQualityTags = [];
  
  List<String> availableCities = [];

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
      allVendorCards = await service.getVendorCardsByCategory(widget.categoryId);
      
      // Fetch cities and tags
      availableCities = await service.getUniqueCities(widget.categoryId);
      availableServiceTags = await service.getAllServiceTags(widget.categoryId);
      availableQualityTags = await service.getAllQualityTags(widget.categoryId);
      
      setState(() {
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
          return selectedServiceTags.every((selectedTag) => 
            card.serviceTags.contains(selectedTag)
          );
        }).toList();
      }

      // Quality tags filter
      if (selectedQualityTags.isNotEmpty) {
        filteredVendorCards = filteredVendorCards.where((card) {
          // Check if ALL selected quality tags are present (AND logic)
          return selectedQualityTags.every((selectedTag) => 
            card.qualityTags.contains(selectedTag)
          );
        }).toList();
      }

      // Budget filter
      if (budgetRange == 'Under 20k') {
        filteredVendorCards = filteredVendorCards
            .where((card) => card.discountedPrice < 20000)
            .toList();
      } else if (budgetRange == '20k-30k') {
        filteredVendorCards = filteredVendorCards
            .where((card) => card.discountedPrice >= 20000 && card.discountedPrice <= 30000)
            .toList();
      } else if (budgetRange == 'Above 30k') {
        filteredVendorCards = filteredVendorCards
            .where((card) => card.discountedPrice > 30000)
            .toList();
      }

      // Sort
      if (sortBy == 'Price: Low to High') {
        filteredVendorCards.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
      } else if (sortBy == 'Price: High to Low') {
        filteredVendorCards.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
      } else if (sortBy == 'Discount') {
        filteredVendorCards.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
      }
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Sort by',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            color: Color(0xff0c1c2c),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('Price: Low to High'),
            _buildSortOption('Price: High to Low'),
            _buildSortOption('Discount'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String option) {
    return RadioListTile<String>(
      title: Text(
        option,
        style: GoogleFonts.urbanist(color: Color(0xff0c1c2c)),
      ),
      value: option,
      groupValue: sortBy,
      activeColor: Color(0xff0c1c2c),
      onChanged: (value) {
        setState(() {
          sortBy = value!;
        });
        Navigator.pop(context);
        _applyFilters();
      },
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          children: [
            _buildBudgetOption('All'),
            _buildBudgetOption('Under 20k'),
            _buildBudgetOption('20k-30k'),
            _buildBudgetOption('Above 30k'),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetOption(String option) {
    return RadioListTile<String>(
      title: Text(
        option,
        style: GoogleFonts.urbanist(color: Color(0xff0c1c2c)),
      ),
      value: option,
      groupValue: budgetRange,
      activeColor: Color(0xff0c1c2c),
      onChanged: (value) {
        setState(() {
          budgetRange = value!;
        });
        Navigator.pop(context);
        _applyFilters();
      },
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
                  _buildFilterChip(
                    label: 'Sort',
                    icon: Icons.sort,
                    onTap: _showSortDialog,
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'City',
                    icon: Icons.location_city,
                    onTap: _showCityDialog,
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Services',
                    icon: Icons.camera_alt,
                    isSelected: selectedServiceTags.isNotEmpty,
                    onTap: _showServiceTagsDialog,
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Quality',
                    icon: Icons.verified,
                    isSelected: selectedQualityTags.isNotEmpty,
                    onTap: _showQualityTagsDialog,
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Budget',
                    icon: Icons.currency_rupee,
                    onTap: _showBudgetDialog,
                  ),
                ],
              ),
            ),
          ),

          // Results count
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 4),
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
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
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
                        serviceType: card.serviceTags.isNotEmpty ? card.serviceTags.first : '',
                        rating: 4.5, // Default since we don't have rating in vendor_cards yet
                        reviewCount: 0, // Default
                        startingPrice: card.formattedDiscountedPrice,
                        originalPrice: card.formattedOriginalPrice,
                        discountPercent: card.discountPercent,
                        imageFileName: card.imagePath,
                        location: card.city,
                        serviceTags: card.serviceTags,
                        qualityTags: card.qualityTags,
                        onViewProfile: () {
                          // Convert VendorCard to Map format for VendorProfilePage
                          final vendorData = {
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
                              builder: (context) => VendorProfilePage(vendorData: vendorData),
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
  }) {
    return GestureDetector(
      onTap: onTap,
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
