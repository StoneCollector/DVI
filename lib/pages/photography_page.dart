import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamventz/components/vendor_tile.dart';

class PhotographyPage extends StatefulWidget {
  final String categoryName;

  const PhotographyPage({super.key, required this.categoryName});

  @override
  State<PhotographyPage> createState() => _PhotographyPageState();
}

class _PhotographyPageState extends State<PhotographyPage> {
  // Static data for photographers
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
  List<String> availableServiceTags = [
    'Wedding Photographer',
    'Videography',
    'Editing',
    'Pre-wedding',
    'Candid Photography',
    'Cinematic Photography',
    'Traditional Photography',
    'Quality Service',
    'Experienced',
    'Customizable',
  ];

  @override
  void initState() {
    super.initState();
    filteredPhotographers = List.from(allPhotographers);
  }

  void _applyFilters() {
    setState(() {
      filteredPhotographers = List.from(allPhotographers);

      // City filter
      if (selectedCity != 'All') {
        filteredPhotographers = filteredPhotographers
            .where((p) => p['location'] == selectedCity)
            .toList();
      }

      // Service tags filter
      if (selectedServiceTags.isNotEmpty) {
        filteredPhotographers = filteredPhotographers.where((p) {
          List<String> photographerServiceTags = List<String>.from(p['serviceTags'] ?? []);
          List<String> photographerQualityTags = List<String>.from(p['qualityTags'] ?? []);
          // Combine both service and quality tags
          List<String> allPhotographerTags = [...photographerServiceTags, ...photographerQualityTags];
          // Check if ALL selected tags are present in the photographer's tags (AND logic)
          return selectedServiceTags.every((selectedTag) => 
            allPhotographerTags.contains(selectedTag)
          );
        }).toList();
      }

      // Budget filter
      if (budgetRange == 'Under 20k') {
        filteredPhotographers = filteredPhotographers
            .where((p) => p['budget'] < 20000)
            .toList();
      } else if (budgetRange == '20k-30k') {
        filteredPhotographers = filteredPhotographers
            .where((p) => p['budget'] >= 20000 && p['budget'] <= 30000)
            .toList();
      } else if (budgetRange == 'Above 30k') {
        filteredPhotographers = filteredPhotographers
            .where((p) => p['budget'] > 30000)
            .toList();
      }

      // Sort
      if (sortBy == 'Rating') {
        filteredPhotographers.sort((a, b) => b['rating'].compareTo(a['rating']));
      } else if (sortBy == 'Price: Low to High') {
        filteredPhotographers.sort((a, b) => a['budget'].compareTo(b['budget']));
      } else if (sortBy == 'Price: High to Low') {
        filteredPhotographers.sort((a, b) => b['budget'].compareTo(a['budget']));
      } else if (sortBy == 'Reviews') {
        filteredPhotographers.sort((a, b) => b['reviewCount'].compareTo(a['reviewCount']));
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
            _buildSortOption('Rating'),
            _buildSortOption('Price: Low to High'),
            _buildSortOption('Price: High to Low'),
            _buildSortOption('Reviews'),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCityOption('All'),
            _buildCityOption('Mumbai'),
            _buildCityOption('Delhi'),
            _buildCityOption('Bangalore'),
            _buildCityOption('Pune'),
            _buildCityOption('Hyderabad'),
          ],
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
      body: Column(
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
                  '${filteredPhotographers.length} vendors found',
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
            child: filteredPhotographers.isEmpty
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
                    itemCount: filteredPhotographers.length,
                    itemBuilder: (context, index) {
                      final photographer = filteredPhotographers[index];
                      return VendorTile(
                        studioName: photographer['studioName'] ?? '',
                        serviceType: photographer['serviceType'] ?? '',
                        rating: photographer['rating'] ?? 0.0,
                        reviewCount: photographer['reviewCount'] ?? 0,
                        startingPrice: photographer['startingPrice'] ?? '0',
                        imageFileName: photographer['imageFileName'] ?? '',
                        location: photographer['location'] ?? 'Mumbai',
                        serviceTags: List<String>.from(photographer['serviceTags'] ?? []),
                        qualityTags: List<String>.from(photographer['qualityTags'] ?? []),
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
