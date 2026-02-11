import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/coordination_service_model.dart';
import '../services/coordination_service.dart';
import '../components/coordination_service_tile.dart';

class CoordinationServicePage extends StatefulWidget {
  const CoordinationServicePage({super.key});

  @override
  State<CoordinationServicePage> createState() =>
      _CoordinationServicePageState();
}

class _CoordinationServicePageState extends State<CoordinationServicePage> {
  final _coordinationService = CoordinationServiceService();
  List<CoordinationService> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => isLoading = true);
    try {
      final fetchedServices = await _coordinationService.getAllServices();
      if (mounted) {
        setState(() {
          services = fetchedServices;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching coordination services: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff0c1c2c),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Coordination Services',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xff0c1c2c),
              ),
            )
          : services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No services available',
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Professional Event Coordination',
                        style: GoogleFonts.urbanist(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff0c1c2c),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Let our experts handle your event logistics',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      
                      // Services Grid
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: services.map((service) {
                          return CoordinationServiceTile(
                            service: service,
                            onBookNow: () {
                              _handleBookService(service);
                            },
                          );
                        }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _handleBookService(CoordinationService service) {
    // TODO: Navigate to booking page or show booking dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${service.title}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
