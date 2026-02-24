import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Carousel form controllers
  final _carouselTitleController = TextEditingController();
  final _carouselSubtitleController = TextEditingController();
  final _carouselOrderController = TextEditingController();
  File? _carouselImage;
  
  // Trending package form controllers
  final _packageTitleController = TextEditingController();
  final _packagePriceController = TextEditingController();
  final _packageOrderController = TextEditingController();
  File? _packageImage;
  
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _carouselTitleController.dispose();
    _carouselSubtitleController.dispose();
    _carouselOrderController.dispose();
    _packageTitleController.dispose();
    _packagePriceController.dispose();
    _packageOrderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCarousel) async {
    // Request permission first
    PermissionStatus status;
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
        status = PermissionStatus.granted;
      } else {
        status = await Permission.photos.request();
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isCarousel) {
            _carouselImage = File(image.path);
          } else {
            _packageImage = File(image.path);
          }
        });
      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please grant photo access in app settings'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo permission is required')),
      );
    }
  }

  Future<String?> _uploadImageToSupabase(File image, String fileName) async {
    try {
      final bytes = await image.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      
      await Supabase.instance.client.storage
          .from('carasol')
          .uploadBinary(uniqueFileName, bytes);
      
      return uniqueFileName;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitCarouselItem() async {
    if (_carouselImage == null || _carouselTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload image
      final fileName = await _uploadImageToSupabase(_carouselImage!, 'carousel.jpg');
      if (fileName == null) throw Exception('Failed to upload image');

      // Insert into database
      await Supabase.instance.client.from('carousel_items').insert({
        'image_filename': fileName,
        'title': _carouselTitleController.text,
        'subtitle': _carouselSubtitleController.text,
        'display_order': int.tryParse(_carouselOrderController.text) ?? 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Carousel item added successfully! Go to Home and swipe down to refresh.'),
          duration: Duration(seconds: 4),
        ),
      );

      // Clear form
      _carouselTitleController.clear();
      _carouselSubtitleController.clear();
      _carouselOrderController.clear();
      setState(() => _carouselImage = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _submitTrendingPackage() async {
    if (_packageImage == null || _packageTitleController.text.isEmpty || _packagePriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload image
      final fileName = await _uploadImageToSupabase(_packageImage!, 'package.jpg');
      if (fileName == null) throw Exception('Failed to upload image');

      // Insert into database
      await Supabase.instance.client.from('trending_packages').insert({
        'image_filename': fileName,
        'title': _packageTitleController.text,
        'price': _packagePriceController.text,
        'display_order': int.tryParse(_packageOrderController.text) ?? 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trending package added successfully! Go to Home and swipe down to refresh.'),
          duration: Duration(seconds: 4),
        ),
      );

      // Clear form
      _packageTitleController.clear();
      _packagePriceController.clear();
      _packageOrderController.clear();
      setState(() => _packageImage = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0c1c2c),
        title: Text('Content Management', style: GoogleFonts.urbanist(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color.fromARGB(255, 212, 175, 55),
          unselectedLabelColor: Colors.white,
          indicatorColor: Color.fromARGB(255, 212, 175, 55),
          tabs: [
            Tab(text: 'Carousel Items'),
            Tab(text: 'Trending Packages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCarouselForm(),
          _buildTrendingPackageForm(),
        ],
      ),
    );
  }

  Widget _buildCarouselForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Carousel Item', style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          
          GestureDetector(
            onTap: () => _pickImage(true),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: _carouselImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_carouselImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Tap to select image', style: GoogleFonts.urbanist()),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 20),
          
          TextField(
            controller: _carouselTitleController,
            decoration: InputDecoration(
              labelText: 'Title *',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 15),
          
          TextField(
            controller: _carouselSubtitleController,
            decoration: InputDecoration(
              labelText: 'Subtitle',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          SizedBox(height: 15),
          
          TextField(
            controller: _carouselOrderController,
            decoration: InputDecoration(
              labelText: 'Display Order',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 25),
          
          ElevatedButton(
            onPressed: _isUploading ? null : _submitCarouselItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff0c1c2c),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: _isUploading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Submit', style: GoogleFonts.urbanist(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingPackageForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Trending Package', style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          
          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: _packageImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_packageImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Tap to select image', style: GoogleFonts.urbanist()),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 20),
          
          TextField(
            controller: _packageTitleController,
            decoration: InputDecoration(
              labelText: 'Package Title *',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 15),
          
          TextField(
            controller: _packagePriceController,
            decoration: InputDecoration(
              labelText: 'Price *',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 15),
          
          TextField(
            controller: _packageOrderController,
            decoration: InputDecoration(
              labelText: 'Display Order',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 25),
          
          ElevatedButton(
            onPressed: _isUploading ? null : _submitTrendingPackage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff0c1c2c),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: _isUploading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Submit', style: GoogleFonts.urbanist(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
