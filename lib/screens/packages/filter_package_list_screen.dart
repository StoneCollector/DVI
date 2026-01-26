import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamventz/screens/packages/package_detail_screen.dart';

class FilterPackageListScreen extends StatefulWidget {
  const FilterPackageListScreen({super.key});

  @override
  State<FilterPackageListScreen> createState() =>
      _FilterPackageListScreenState();
}

class _FilterPackageListScreenState extends State<FilterPackageListScreen> {
  final supabase = Supabase.instance.client;

  List venues = [];
  List<String> areaList = ['All Areas'];
  List<String> venueTypeList = ['All Types'];

  String selectedArea = 'All Areas';
  String selectedVenueType = 'All Types';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFiltersAndVenues();
  }

  Future<void> loadFiltersAndVenues() async {
    final allVenues = await supabase.from('venues').select();

    final areas = <String>{};
    final types = <String>{};

    for (var v in allVenues) {
      if (v['location'] != null) areas.add(v['location']);
      if (v['venue_type'] != null) types.add(v['venue_type']);
    }

    setState(() {
      areaList = ['All Areas', ...areas];
      venueTypeList = ['All Types', ...types];
    });

    await fetchVenues();
    setState(() => isLoading = false);
  }

  Future<void> fetchVenues() async {
    var query = supabase.from('venues').select('*, venue_images(image_url)');

    if (selectedArea != 'All Areas') {
      query = query.eq('location', selectedArea);
    }
    if (selectedVenueType != 'All Types') {
      query = query.eq('venue_type', selectedVenueType);
    }

    venues = await query;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F7),
      appBar: AppBar(
        title: const Text(
          'Pre-Designed Packages',
          style: TextStyle(color: Color(0xffA61C4D)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xffA61C4D)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdown('Filter by Area', selectedArea, areaList, (v) {
              selectedArea = v!;
              fetchVenues();
            }),
            const SizedBox(height: 12),
            _buildDropdown(
              'Filter by Venue Type',
              selectedVenueType,
              venueTypeList,
              (v) {
                selectedVenueType = v!;
                fetchVenues();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : venues.isEmpty
                  ? const Center(
                      child: Text(
                        'No venues found. Add some in your Supabase database!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: venues.length,
                      itemBuilder: (context, i) {
                        final v = venues[i];
                        final img = v['venue_images'].isNotEmpty
                            ? v['venue_images'][0]['image_url']
                            : null;

                        return _packageCard(context, v, img);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _packageCard(BuildContext context, Map v, String? img) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              if (img != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    img,
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 190,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.white),
                  ),
                ),
              Positioned(
                top: 12,
                left: 12,
                child: _badge('Available', Colors.green),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _badge('₹ ${v['price']}', const Color(0xffA61C4D)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xffA61C4D),
                    ),
                    const SizedBox(width: 4),
                    Text(v['location']),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  v['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups, size: 18),
                        const SizedBox(width: 4),
                        Text('Up to ${v['capacity']}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.restaurant, size: 18),
                        const SizedBox(width: 4),
                        Text(v['food_type']),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffA61C4D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PackageDetailScreen(venue: v),
                        ),
                      );
                    },
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffF3C2D3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
