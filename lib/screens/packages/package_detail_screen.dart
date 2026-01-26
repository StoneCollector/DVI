import 'package:flutter/material.dart';

class PackageDetailScreen extends StatelessWidget {
  final Map venue;

  const PackageDetailScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final img = venue['venue_images'].isNotEmpty
        ? venue['venue_images'][0]['image_url']
        : null;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xffFFF5F7),
        body: Column(
          children: [
            Stack(
              children: [
                if (img != null)
                  Image.network(
                    img,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    height: 260,
                    width: double.infinity,
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(Icons.image, size: 80, color: Colors.white),
                    ),
                  ),
                Positioned(
                  top: 40,
                  left: 12,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const TabBar(
              labelColor: Color(0xffA61C4D),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xffA61C4D),
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Gallery'),
                Tab(text: 'Services'),
                Tab(text: 'Menu'),
                Tab(text: 'Decor'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _overview(),
                  const Center(child: Text('Gallery Coming Soon')),
                  const Center(child: Text('Services Coming Soon')),
                  const Center(child: Text('Menu Coming Soon')),
                  const Center(child: Text('Decor Coming Soon')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overview() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(venue['location']),
            const SizedBox(height: 20),
            _info('Capacity', 'Up to ${venue['capacity']}'),
            _info('Food Options', venue['food_type']),
            _info('Venue Type', venue['venue_type']),
            const SizedBox(height: 20),
            const Text(
              'About This Venue',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(venue['description'] ?? 'No description'),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
