import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/vendor_tile.dart';
import 'package:dreamventz/models/vendor_card.dart';
import 'package:dreamventz/services/vendor_card_service.dart';

class PhotographyPage extends StatefulWidget {
  final String categoryName;
  final int categoryId;

  const PhotographyPage({
    super.key, 
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<PhotographyPage> createState() => _PhotographyPageState();
}

class _PhotographyPageState extends State<PhotographyPage> {

  // Data from Supabase
  List<VendorCard> allVendorCards = [];
  List<VendorCard> filteredVendorCards = [];
  bool isLoading = true;
  String? errorMessage;

  // Static data for photographers (BACKUP - will be replaced by Supabase data)
  List<Map<String, dynamic>> allPhotographers = [
    {
      'studioName': 'Raj Photo Studio',
      'serviceType': 'Wedding Photography',
      'rating': 4.8,
      'reviewCount': 320,
      'startingPrice': '25,000',
      'imageFileName': 'hero7.jpg',
      'preWedding': true,
      'budget': 25000,
      'location': 'Mumbai',
      'serviceTags': ['Wedding Photographer', 'Editing'],
      'qualityTags': ['Quality Service'],
    },
    {
      'studioName': 'Creative Frame Studio',
      'serviceType': 'Pre-wedding & Wedding Photography',
      'rating': 4.9,
      'reviewCount': 215,
      'startingPrice': '18,000',
      'imageFileName': 'hero2.jpg',
      'preWedding': true,
      'budget': 18000,
      'location': 'Delhi',
      'serviceTags': ['Pre-wedding', 'Videography'],
      'qualityTags': ['Customizable'],
    },
    {
      'studioName': 'SnapSutra',
      'serviceType': 'Candid Photography',
      'rating': 4.9,
      'reviewCount': 180,
      'startingPrice': '30,000',
      'imageFileName': 'hero3.jpg',
      'preWedding': true,
      'budget': 30000,
      'location': 'Bangalore',
      'serviceTags': ['Candid Photography', 'Editing'],
      'qualityTags': ['Experienced'],
    },
    {
      'studioName': 'Pixel Perfect Photos',
      'serviceType': 'Wedding Photography',
      'rating': 4.7,
      'reviewCount': 275,
      'startingPrice': '28,000',
      'imageFileName': 'hero4.jpg',
      'preWedding': true,
      'budget': 28000,
      'location': 'Mumbai',
      'serviceTags': ['Wedding Photographer', 'Traditional Photography'],
      'qualityTags': ['Customizable'],
    },
    {
      'studioName': 'Moments Capture',
      'serviceType': 'Cinematic Photography',
      'rating': 4.6,
      'reviewCount': 156,
      'startingPrice': '22,000',
      'imageFileName': 'hero5.jpg',
      'preWedding': false,
      'budget': 22000,
      'location': 'Pune',
      'serviceTags': ['Cinematic Photography', 'Videography'],
      'qualityTags': ['Experienced'],
    },
    {
      'studioName': 'Dream Lens Studios',
      'serviceType': 'Traditional & Candid',
      'rating': 4.8,
      'reviewCount': 298,
      'startingPrice': '35,000',
      'imageFileName': 'hero6.jpg',
      'preWedding': true,
      'budget': 35000,
      'location': 'Hyderabad',
      'serviceTags': ['Traditional Photography', 'Pre-wedding'],
      'qualityTags': ['Quality Service'],
    },
  ];

  List<Map<String, dynamic>> filteredPhotographers = [];

  // Filter states
  String sortBy = 'Rating';
  bool preWeddingOnly = false;
  String budgetRange = 'All';
  String selectedCity = 'All';
  
  // Service tags filter
  List<String> selectedServiceTags = [];
  List<String> availableServiceTags = [];
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
          // Combine both service and quality tags
          List<String> allTags = [...card.serviceTags, ...card.qualityTags];
          // Check if ALL selected tags are present in the card's tags (AND logic)
          return selectedServiceTags.every((selectedTag) => 
            allTags.contains(selectedTag)
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
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text(
                                  'Coming Soon',
                                  style: GoogleFonts.urbanist(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff0c1c2c),
                                  ),
                                ),
                                content: Text(
                                  'Vendor profile details will be available soon!',
                                  style: GoogleFonts.urbanist(
                                    color: Color(0xff0c1c2c),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'OK',
                                      style: GoogleFonts.urbanist(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff0c1c2c),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
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
