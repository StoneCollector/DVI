import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamventz/models/venue_models.dart';
import 'package:dreamventz/services/venue_service.dart';
import 'package:dreamventz/services/vendor_card_service.dart';
import 'package:dreamventz/utils/supabase_config.dart';
import 'package:dreamventz/pages/vendor_profile_page.dart';
import 'package:dreamventz/components/customized_vendor_tile.dart';
import 'package:dreamventz/components/customized_venue_tile.dart';

class CustomizePackagePage extends StatefulWidget {
  const CustomizePackagePage({super.key});

  @override
  State<CustomizePackagePage> createState() => _CustomizePackagePageState();
}

class _CustomizePackagePageState extends State<CustomizePackagePage> {
  int currentStep = 1;
  final _venueService = VenueService();
  
  // Loading states
  bool isLoadingVenues = false;
  bool isLoadingVendors = false;

  // Data
  List<VenueData> venues = [];
  Map<int, List<Map<String, dynamic>>> vendorsByCategory = {};
  
  // Package data
  Map<String, dynamic> packageData = {
    // Step 1: Event Basics
    'eventName': '',
    'eventType': '',
    'serviceRequirement': 'both', // 'both' | 'vendors'
    'venueDetails': '',
    'eventDate': '',
    'startTime': '',
    'endTime': '',
    'location': '',
    'guestCount': 100,
    
    // Step 2: Selections
    'selectedVenue': null,
    'selectedPhotographer': null,
    'selectedMehndiArtist': null,
    'selectedMakeupArtist': null,
    'selectedCaterer': null,
    'selectedDJ': null,
    'selectedDecorator': null,
    'selectedPandit': null,
    'selectedInvites': null,
  };

  // Validation errors
  Map<String, String> errors = {};
  
  // Active vendor tab
  String activeVendorTab = 'venue';

  // Vendor filter states
  String vendorSortBy = 'Rating';
  String vendorBudgetRange = 'All';
  List<String> selectedServiceTags = [];
  List<String> selectedQualityTags = [];

  // Vendor categories mapping (id to name)
  final Map<int, String> categoryMap = {
    1: 'Photography',
    2: 'Mehndi Artist',
    3: 'Make-Up Artist',
    4: 'Caterers',
    5: 'DJ & Bands',
    6: 'Decorators',
    7: 'Pandits',
    8: 'Invites & Gifts',
  };

  @override
  void initState() {
    super.initState();
    _fetchVenues();
    _fetchAllVendors();
  }

  Future<void> _fetchVenues() async {
    if (!mounted) return;
    setState(() => isLoadingVenues = true);
    try {
      final allVenues = await _venueService.getAllPublicVenues();
      if (!mounted) return;
      setState(() {
        venues = allVenues;
        isLoadingVenues = false;
      });
    } catch (e) {
      debugPrint('Error fetching venues: $e');
      if (!mounted) return;
      setState(() => isLoadingVenues = false);
    }
  }

  Future<void> _fetchAllVendors() async {
    if (!mounted) return;
    setState(() => isLoadingVendors = true);
    try {
      for (var categoryId in categoryMap.keys) {
        final response = await Supabase.instance.client
            .from('vendor_cards')
            .select()
            .eq('category_id', categoryId);
        
        vendorsByCategory[categoryId] = List<Map<String, dynamic>>.from(response);
      }
      if (!mounted) return;
      setState(() => isLoadingVendors = false);
    } catch (e) {
      debugPrint('Error fetching vendors: $e');
      if (!mounted) return;
      setState(() => isLoadingVendors = false);
    }
  }

  String formatCurrency(double value) {
    return '₹${value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  double calculateTotal() {
    double total = 0;
    
    // Venue
    if (packageData['selectedVenue'] != null) {
      final venue = packageData['selectedVenue'] as VenueData;
      total += venue.discountedVenuePrice;
    }
    
    // Vendors
    final vendorKeys = [
      'selectedPhotographer',
      'selectedMehndiArtist',
      'selectedMakeupArtist',
      'selectedCaterer',
      'selectedDJ',
      'selectedDecorator',
      'selectedPandit',
      'selectedInvites',
    ];
    
    for (var key in vendorKeys) {
      if (packageData[key] != null) {
        final vendor = packageData[key] as Map<String, dynamic>;
        final price = vendor['discounted_price'];
        if (price != null) {
          total += (price is int ? price.toDouble() : price as double);
        }
      }
    }
    
    return total;
  }

  bool isEventBasicsValid() {
    errors.clear();
    
    if (packageData['eventName'].toString().trim().isEmpty) {
      errors['eventName'] = 'Event name is required';
    }
    if (packageData['eventType'].toString().isEmpty) {
      errors['eventType'] = 'Event type is required';
    }
    if (packageData['eventDate'].toString().isEmpty) {
      errors['eventDate'] = 'Event date is required';
    }
    if (packageData['location'].toString().isEmpty) {
      errors['location'] = 'Location is required';
    }
    if (packageData['guestCount'] == null || packageData['guestCount'] <= 0) {
      errors['guestCount'] = 'Guest count must be greater than 0';
    }
    
    // Validate venue details if "Vendors Only" is selected
    if (packageData['serviceRequirement'] == 'vendors' && 
        packageData['venueDetails'].toString().trim().isEmpty) {
      errors['venueDetails'] = 'Please enter your venue details';
    }
    
    setState(() {});
    return errors.isEmpty;
  }

  void handleNext() {
    if (currentStep == 1 && !isEventBasicsValid()) {
      return;
    }
    
    if (currentStep < 4) {
      setState(() => currentStep++);
    }
  }

  void handleBack() {
    if (currentStep > 1) {
      setState(() => currentStep--);
    }
  }

  void handleConfirmBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text(
              'Booking Confirmed!',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xff0c1c2c),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your custom package has been created successfully!',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Color(0xff0c1c2c),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff0c1c2c),
                    ),
                  ),
                  Text(
                    formatCurrency(calculateTotal()),
                    style: GoogleFonts.urbanist(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Our team will contact you shortly to confirm the booking details.',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: Color(0xff0c1c2c),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to home
            },
            child: Text(
              'OK',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xff0c1c2c),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Color(0xff0c1c2c),
        foregroundColor: Colors.white,
        title: Text(
          'Customize Your Package',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step Indicator
          _buildStepIndicator(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  key: ValueKey<int>(currentStep),
                  children: [
                    if (currentStep == 1) _buildEventBasics(),
                    if (currentStep == 2) _buildVendorServices(),
                    if (currentStep == 3) _buildReview(),
                    if (currentStep == 4) _buildConfirmation(),
                  ],
                ),
              ),
            ),
          ),
          
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStepCircle(1, 'Event\nBasics'),
          _buildStepConnector(1),
          _buildStepCircle(2, 'Vendor\nServices'),
          _buildStepConnector(2),
          _buildStepCircle(3, 'Review\n'),
          _buildStepConnector(3),
          _buildStepCircle(4, 'Confirm\n'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = currentStep >= step;
    return Expanded(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? Color(0xff0c1c2c) : Colors.grey[300],
                shape: BoxShape.circle,
                boxShadow: isActive ? [
                  BoxShadow(
                    color: Color(0xff0c1c2c).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ] : [],
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.urbanist(
                fontSize: 9,
                height: 1.1,
                color: isActive ? Color(0xff0c1c2c) : Colors.grey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isActive = currentStep > step;
    return Expanded(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 2,
        margin: EdgeInsets.only(bottom: 22, left: 4, right: 4),
        color: isActive ? Color(0xff0c1c2c) : Colors.grey[300],
      ),
    );
  }

  Widget _buildEventBasics() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about your event',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff0c1c2c),
            ),
          ),
          SizedBox(height: 12),
          
          // Event Name
          _buildTextField(
            label: 'Event Name',
            hint: 'e.g. Rahul\'s Wedding',
            value: packageData['eventName'],
            error: errors['eventName'],
            onChanged: (value) => setState(() => packageData['eventName'] = value),
          ),
          SizedBox(height: 12),
          
          // Event Type
          _buildDropdown(
            label: 'Event Type',
            value: packageData['eventType'],
            error: errors['eventType'],
            items: ['Wedding', 'Birthday', 'Corporate', 'Anniversary'],
            onChanged: (value) => setState(() => packageData['eventType'] = value),
          ),
          SizedBox(height: 12),
          
          // Service Requirement
          Text(
            'What services do you need?',
            style: GoogleFonts.urbanist(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff0c1c2c),
            ),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildServiceTypeCard(
                  'Venue & Vendors',
                  'I need both a venue and services',
                  'both',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildServiceTypeCard(
                  'Vendors Only',
                  'I already have a venue',
                  'vendors',
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Venue Details (if Vendors Only)
          if (packageData['serviceRequirement'] == 'vendors') ...[
            _buildTextField(
              label: 'Existing Venue Details',
              hint: 'Enter the name and address of your venue...',
              value: packageData['venueDetails'],
              error: errors['venueDetails'],
              maxLines: 3,
              onChanged: (value) => setState(() => packageData['venueDetails'] = value),
            ),
            SizedBox(height: 12),
          ],
          
          // Event Date
          _buildDateField(
            label: 'Event Date',
            value: packageData['eventDate'],
            error: errors['eventDate'],
            onChanged: (value) => setState(() => packageData['eventDate'] = value),
          ),
          SizedBox(height: 12),
          
          // Time
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  label: 'Start Time',
                  value: packageData['startTime'],
                  onChanged: (value) => setState(() => packageData['startTime'] = value),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildTimeField(
                  label: 'End Time',
                  value: packageData['endTime'],
                  onChanged: (value) => setState(() => packageData['endTime'] = value),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Location
          _buildTextField(
            label: 'City/Area',
            hint: 'Enter your city (e.g., Mumbai)',
            value: packageData['location'],
            error: errors['location'],
            onChanged: (value) => setState(() => packageData['location'] = value),
          ),
          SizedBox(height: 12),
          
          // Guest Count
          _buildTextField(
            label: 'Guest Count',
            hint: '100',
            value: packageData['guestCount'].toString(),
            error: errors['guestCount'],
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() => packageData['guestCount'] = int.tryParse(value) ?? 0),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTypeCard(String title, String subtitle, String value) {
    final isSelected = packageData['serviceRequirement'] == value;
    return GestureDetector(
      onTap: () => setState(() => packageData['serviceRequirement'] = value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff0c1c2c).withValues(alpha: 0.05) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? Color(0xff0c1c2c) : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Color(0xff0c1c2c).withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Color(0xff0c1c2c) : Colors.grey,
                  size: 18,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xff0c1c2c),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3),
            Padding(
              padding: EdgeInsets.only(left: 24),
              child: Text(
                subtitle,
                style: GoogleFonts.urbanist(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String value,
    String? error,
    int maxLines = 1,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff0c1c2c),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.urbanist(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.urbanist(fontSize: 12),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xff0c1c2c), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            errorText: error,
            errorStyle: GoogleFonts.urbanist(fontSize: 10),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    String? error,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff0c1c2c),
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value.isEmpty ? null : value,
          dropdownColor: Colors.white,
          style: GoogleFonts.urbanist(
            fontSize: 13,
            color: Color(0xff0c1c2c),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xff0c1c2c), width: 2),
            ),
            errorText: error,
            errorStyle: GoogleFonts.urbanist(fontSize: 10),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  color: Color(0xff0c1c2c),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    String? error,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff0c1c2c),
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(Duration(days: 7)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (date != null && mounted) {
              onChanged(date.toString().split(' ')[0]);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              suffixIcon: Icon(Icons.calendar_today, color: Color(0xff0c1c2c)),
              errorText: error,
            ),
            child: Text(
              value.isEmpty ? 'Select Date' : value,
              style: GoogleFonts.urbanist(
                color: value.isEmpty ? Colors.grey : Color(0xff0c1c2c),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff0c1c2c),
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (time != null && mounted) {
              onChanged('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              suffixIcon: Icon(Icons.access_time, color: Color(0xff0c1c2c)),
            ),
            child: Text(
              value.isEmpty ? 'Select Time' : value,
              style: GoogleFonts.urbanist(
                color: value.isEmpty ? Colors.grey : Color(0xff0c1c2c),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorServices() {
    // Determine which tabs to show
    List<Map<String, dynamic>> tabs = [];
    
    if (packageData['serviceRequirement'] == 'both') {
      tabs.add({'id': 'venue', 'label': 'Venue', 'icon': Icons.location_on});
    }
    
    tabs.addAll([
      {'id': 'photography', 'label': 'Photography', 'icon': Icons.camera_alt},
      {'id': 'mehndi', 'label': 'Mehndi', 'icon': Icons.brush},
      {'id': 'makeup', 'label': 'Makeup', 'icon': Icons.face},
      {'id': 'catering', 'label': 'Catering', 'icon': Icons.restaurant},
      {'id': 'dj', 'label': 'DJ & Bands', 'icon': Icons.music_note},
      {'id': 'decor', 'label': 'Decorators', 'icon': Icons.auto_awesome},
      {'id': 'pandits', 'label': 'Pandits', 'icon': Icons.self_improvement},
      {'id': 'invites', 'label': 'Invites', 'icon': Icons.card_giftcard},
    ]);
    
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '   Select Your Services',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff0c1c2c),
            ),
          ),
          SizedBox(height: 6),
          
          // Tabs
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isActive = activeVendorTab == tab['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      activeVendorTab = tab['id'];
                      // Clear filters when switching tabs
                      selectedServiceTags = [];
                      selectedQualityTags = [];
                      vendorBudgetRange = 'All';
                      vendorSortBy = 'Rating';
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 6),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? Color(0xff0c1c2c) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab['icon'],
                          size: 16,
                          color: isActive ? Colors.white : Colors.grey[700],
                        ),
                        SizedBox(width: 6),
                        Text(
                          tab['label'],
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            color: isActive ? Colors.white : Colors.grey[700],
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Filter chips (only for vendor tabs, not venue)
          if (activeVendorTab != 'venue') ...[
            Container(
              padding: EdgeInsets.symmetric( vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Sort',
                      icon: Icons.sort,
                      onTap: _showVendorSortDialog,
                    ),
                    SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'Services',
                      icon: Icons.camera_alt,
                      isSelected: selectedServiceTags.isNotEmpty,
                      onTap: _showVendorServiceTagsDialog,
                    ),
                    SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'Quality',
                      icon: Icons.verified,
                      isSelected: selectedQualityTags.isNotEmpty,
                      onTap: _showVendorQualityTagsDialog,
                    ),
                    SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'Budget',
                      icon: Icons.currency_rupee,
                      onTap: _showVendorBudgetDialog,
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Content based on active tab
          if (activeVendorTab == 'venue')
            _buildVenueSelection()
          else
            _buildVendorSelection(activeVendorTab),
        ],
      ),
    );
  }

  Widget _buildVenueSelection() {
    if (isLoadingVenues) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: Color(0xff0c1c2c)),
        ),
      );
    }
    
    // Filter venues by selected location
    final selectedLocation = packageData['location']?.toString().trim().toLowerCase() ?? '';
    final filteredVenues = selectedLocation.isEmpty 
        ? venues 
        : venues.where((venue) => venue.shortLocation.toLowerCase().trim().contains(selectedLocation) || venue.locationAddress?.toLowerCase().contains(selectedLocation) == true).toList();
    
    if (filteredVenues.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            selectedLocation.isEmpty ? 'No venues available' : 'No venues available in $selectedLocation',
            style: GoogleFonts.urbanist(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return Column(
      children: filteredVenues.map((venue) {
        final isSelected = packageData['selectedVenue'] == venue;
        return CustomizedVenueTile(
          venue: venue,
          isSelected: isSelected,
          onTap: () => setState(() => packageData['selectedVenue'] = isSelected ? null : venue),
        );
      }).toList(),
    );
  }

  Widget _buildVendorSelection(String tabId) {
    // Map tab id to category id
    final categoryIdMap = {
      'photography': 1,
      'mehndi': 2,
      'makeup': 3,
      'catering': 4,
      'dj': 5,
      'decor': 6,
      'pandits': 7,
      'invites': 8,
    };
    
    final selectionKeyMap = {
      'photography': 'selectedPhotographer',
      'mehndi': 'selectedMehndiArtist',
      'makeup': 'selectedMakeupArtist',
      'catering': 'selectedCaterer',
      'dj': 'selectedDJ',
      'decor': 'selectedDecorator',
      'pandits': 'selectedPandit',
      'invites': 'selectedInvites',
    };
    
    final categoryId = categoryIdMap[tabId];
    final selectionKey = selectionKeyMap[tabId];
    
    if (categoryId == null || selectionKey == null) {
      return Center(child: Text('Invalid category'));
    }
    
    if (isLoadingVendors) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: Color(0xff0c1c2c)),
        ),
      );
    }
    
    final vendors = vendorsByCategory[categoryId] ?? [];
    
    // Apply filters
    var filteredVendors = List<Map<String, dynamic>>.from(vendors);
    
    // Location filter
    final selectedLocation = packageData['location']?.toString().trim().toLowerCase() ?? '';
    if (selectedLocation.isNotEmpty) {
      filteredVendors = filteredVendors.where((vendor) => 
        (vendor['city']?.toString().toLowerCase().trim() ?? '').contains(selectedLocation)
      ).toList();
    }
    
    // Service tags filter
    if (selectedServiceTags.isNotEmpty) {
      filteredVendors = filteredVendors.where((vendor) {
        final vendorTags = List<String>.from(vendor['service_tags'] ?? []);
        return selectedServiceTags.every((tag) => vendorTags.contains(tag));
      }).toList();
    }
    
    // Quality tags filter
    if (selectedQualityTags.isNotEmpty) {
      filteredVendors = filteredVendors.where((vendor) {
        final vendorTags = List<String>.from(vendor['quality_tags'] ?? []);
        return selectedQualityTags.every((tag) => vendorTags.contains(tag));
      }).toList();
    }
    
    // Budget filter
    if (vendorBudgetRange == 'Under 20k') {
      filteredVendors = filteredVendors.where((vendor) => 
        (vendor['discounted_price'] ?? 0) < 20000
      ).toList();
    } else if (vendorBudgetRange == '20k-30k') {
      filteredVendors = filteredVendors.where((vendor) {
        final price = vendor['discounted_price'] ?? 0;
        return price >= 20000 && price <= 30000;
      }).toList();
    } else if (vendorBudgetRange == 'Above 30k') {
      filteredVendors = filteredVendors.where((vendor) => 
        (vendor['discounted_price'] ?? 0) > 30000
      ).toList();
    }
    
    // Sort
    if (vendorSortBy == 'Price: Low to High') {
      filteredVendors.sort((a, b) => 
        (a['discounted_price'] ?? 0).compareTo(b['discounted_price'] ?? 0)
      );
    } else if (vendorSortBy == 'Price: High to Low') {
      filteredVendors.sort((a, b) => 
        (b['discounted_price'] ?? 0).compareTo(a['discounted_price'] ?? 0)
      );
    }
    
    if (filteredVendors.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
              SizedBox(height: 12),
              Text(
                'No vendors found',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                'Try adjusting your filters',
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: filteredVendors.map((vendor) {
        final isSelected = packageData[selectionKey] == vendor;
        return CustomizedVendorTile(
          vendor: vendor,
          isSelected: isSelected,
          onTap: () => setState(() => packageData[selectionKey] = isSelected ? null : vendor),
        );
      }).toList(),
    );
  }

  Widget _buildReview() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Package',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff0c1c2c),
            ),
          ),
          SizedBox(height: 12),
          
          // Event Details
          _buildReviewSection(
            'Event Details',
            [
              {'label': 'Event Name', 'value': packageData['eventName']},
              {'label': 'Event Type', 'value': packageData['eventType']},
              {'label': 'Date', 'value': packageData['eventDate']},
              {'label': 'Time', 'value': '${packageData['startTime']} - ${packageData['endTime']}'},
              {'label': 'Location', 'value': packageData['location']},
              {'label': 'Guests', 'value': packageData['guestCount'].toString()},
            ],
          ),
          
          // Venue Details
          if (packageData['serviceRequirement'] == 'vendors' && packageData['venueDetails'].toString().isNotEmpty)
            _buildReviewSection(
              'Your Venue',
              [{'label': 'Venue Details', 'value': packageData['venueDetails']}],
            ),
          if (packageData['selectedVenue'] != null)
            _buildReviewItem(
              'Selected Venue',
              (packageData['selectedVenue'] as VenueData).name,
              formatCurrency((packageData['selectedVenue'] as VenueData).discountedVenuePrice),
            ),
          
          // Selected Vendors
          if (packageData['selectedPhotographer'] != null)
            _buildReviewItem(
              'Photographer',
              packageData['selectedPhotographer']['studio_name'],
              '₹${packageData['selectedPhotographer']['discounted_price']}',
            ),
          if (packageData['selectedMehndiArtist'] != null)
            _buildReviewItem(
              'Mehndi Artist',
              packageData['selectedMehndiArtist']['studio_name'],
              '₹${packageData['selectedMehndiArtist']['discounted_price']}',
            ),
          if (packageData['selectedMakeupArtist'] != null)
            _buildReviewItem(
              'Makeup Artist',
              packageData['selectedMakeupArtist']['studio_name'],
              '₹${packageData['selectedMakeupArtist']['discounted_price']}',
            ),
          if (packageData['selectedCaterer'] != null)
            _buildReviewItem(
              'Caterer',
              packageData['selectedCaterer']['studio_name'],
              '₹${packageData['selectedCaterer']['discounted_price']}',
            ),
          if (packageData['selectedDJ'] != null)
            _buildReviewItem(
              'DJ & Bands',
              packageData['selectedDJ']['studio_name'],
              '₹${packageData['selectedDJ']['discounted_price']}',
            ),
          if (packageData['selectedDecorator'] != null)
            _buildReviewItem(
              'Decorator',
              packageData['selectedDecorator']['studio_name'],
              '₹${packageData['selectedDecorator']['discounted_price']}',
            ),
          if (packageData['selectedPandit'] != null)
            _buildReviewItem(
              'Pandit',
              packageData['selectedPandit']['studio_name'],
              '₹${packageData['selectedPandit']['discounted_price']}',
            ),
          if (packageData['selectedInvites'] != null)
            _buildReviewItem(
              'Invites & Gifts',
              packageData['selectedInvites']['studio_name'],
              '₹${packageData['selectedInvites']['discounted_price']}',
            ),
          
          Divider(height: 16),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Estimated Cost',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatCurrency(calculateTotal()),
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xff0c1c2c),
          ),
        ),
        SizedBox(height: 6),
        ...items.map((item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label']!,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      item['value']!,
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            )),
        Divider(),
      ],
    );
  }

  Widget _buildReviewItem(String label, String name, String price) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.urbanist(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  name,
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 50,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Ready to Book!',
            style: GoogleFonts.urbanist(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff0c1c2c),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your custom package is ready. \nThe total amount is:',
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              formatCurrency(calculateTotal()),
              style: GoogleFonts.urbanist(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: handleConfirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff0c1c2c),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirm Booking',
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 1)
            Expanded(
              child: AnimatedScale(
                scale: 1.0,
                duration: Duration(milliseconds: 200),
                child: OutlinedButton(
                  onPressed: handleBack,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Color(0xff0c1c2c)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0c1c2c),
                    ),
                  ),
                ),
              ),
            ),
          if (currentStep > 1) SizedBox(width: 10),
          if (currentStep < 4)
            Expanded(
              flex: currentStep == 1 ? 1 : 1,
              child: AnimatedScale(
                scale: 1.0,
                duration: Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: handleNext,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Color(0xff0c1c2c),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods to get available tags from current vendors
  List<String> _getAvailableServiceTags() {
    final categoryIdMap = {
      'photography': 1,
      'mehndi': 2,
      'makeup': 3,
      'catering': 4,
      'dj': 5,
      'decor': 6,
      'pandits': 7,
      'invites': 8,
    };
    
    final categoryId = categoryIdMap[activeVendorTab];
    if (categoryId == null) return [];
    
    final vendors = vendorsByCategory[categoryId] ?? [];
    
    // Filter by location only (not by tags, to show available options)
    final selectedLocation = packageData['location']?.toString().trim().toLowerCase() ?? '';
    var locationFilteredVendors = vendors;
    if (selectedLocation.isNotEmpty) {
      locationFilteredVendors = vendors.where((vendor) => 
        (vendor['city']?.toString().toLowerCase().trim() ?? '').contains(selectedLocation)
      ).toList();
    }
    
    // Extract all unique service tags from these vendors
    final Set<String> tags = {};
    for (var vendor in locationFilteredVendors) {
      final vendorTags = List<String>.from(vendor['service_tags'] ?? []);
      tags.addAll(vendorTags);
    }
    
    final tagList = tags.toList();
    tagList.sort();
    return tagList;
  }
  
  List<String> _getAvailableQualityTags() {
    final categoryIdMap = {
      'photography': 1,
      'mehndi': 2,
      'makeup': 3,
      'catering': 4,
      'dj': 5,
      'decor': 6,
      'pandits': 7,
      'invites': 8,
    };
    
    final categoryId = categoryIdMap[activeVendorTab];
    if (categoryId == null) return [];
    
    final vendors = vendorsByCategory[categoryId] ?? [];
    
    // Filter by location only (not by tags, to show available options)
    final selectedLocation = packageData['location']?.toString().trim().toLowerCase() ?? '';
    var locationFilteredVendors = vendors;
    if (selectedLocation.isNotEmpty) {
      locationFilteredVendors = vendors.where((vendor) => 
        (vendor['city']?.toString().toLowerCase().trim() ?? '').contains(selectedLocation)
      ).toList();
    }
    
    // Extract all unique quality tags from these vendors
    final Set<String> tags = {};
    for (var vendor in locationFilteredVendors) {
      final vendorTags = List<String>.from(vendor['quality_tags'] ?? []);
      tags.addAll(vendorTags);
    }
    
    final tagList = tags.toList();
    tagList.sort();
    return tagList;
  }

  // Filter methods
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff0c1c2c) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xff0c1c2c) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVendorSortDialog() {
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
      groupValue: vendorSortBy,
      activeColor: Color(0xff0c1c2c),
      onChanged: (value) {
        setState(() {
          vendorSortBy = value!;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showVendorServiceTagsDialog() {
    final availableTags = _getAvailableServiceTags();
    
    if (availableTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No service tags available for displayed vendors'),
          backgroundColor: Colors.grey[700],
        ),
      );
      return;
    }
    
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
                children: availableTags.map((tag) {
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

  void _showVendorQualityTagsDialog() {
    final availableTags = _getAvailableQualityTags();
    
    if (availableTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No quality tags available for displayed vendors'),
          backgroundColor: Colors.grey[700],
        ),
      );
      return;
    }
    
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
                children: availableTags.map((tag) {
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

  void _showVendorBudgetDialog() {
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
      groupValue: vendorBudgetRange,
      activeColor: Color(0xff0c1c2c),
      onChanged: (value) {
        setState(() {
          vendorBudgetRange = value!;
        });
        Navigator.pop(context);
      },
    );
  }
}
