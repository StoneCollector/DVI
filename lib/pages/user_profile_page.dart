import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamventz/config/supabase_config.dart';
import 'package:dreamventz/models/user_model.dart';
import 'package:dreamventz/services/user_service.dart';
import 'package:dreamventz/utils/constants.dart';
import 'package:dreamventz/utils/validators.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with TickerProviderStateMixin {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  UserModel? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  File? _selectedImage;

  // Animation controllers
  late AnimationController _staggerController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _pinCodeController;
  late TextEditingController _cityController;
  late TextEditingController _ageController;
  String? _selectedState;
  String? _selectedGender;

  // Indian states list
  final List<String> _indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
    'Jammu & Kashmir',
    'Ladakh',
  ];

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _loadUserProfile();
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _pinCodeController = TextEditingController();
    _cityController = TextEditingController();
    _ageController = TextEditingController();
  }

  void _initAnimations() {
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for 8 field cards
    _fadeAnimations = [];
    _slideAnimations = [];

    for (int i = 0; i < 8; i++) {
      final start = i * 0.1;
      final end = start + 0.4;

      _fadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
          ),
        ),
      );

      _slideAnimations.add(
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(
              start,
              end.clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _userService.getCurrentUserProfile();
      final user = SupabaseConfig.currentUser;

      setState(() {
        _userProfile = profile?.copyWith(email: user?.email ?? profile.email);
        _isLoading = false;

        if (_userProfile != null) {
          _nameController.text = _userProfile!.fullName;
          _phoneController.text = _userProfile!.phone ?? '';
          _addressController.text = _userProfile!.address ?? '';
          _pinCodeController.text = _userProfile!.pinCode ?? '';
          _cityController.text = _userProfile!.city ?? '';
          _ageController.text = _userProfile!.age?.toString() ?? '';
          _selectedState = _userProfile!.state;
          _selectedGender = _userProfile!.gender;
        }
      });

      // Start animations after data loaded
      _staggerController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;

    PermissionStatus status;
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted ||
          await Permission.storage.isGranted) {
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
        setState(() => _selectedImage = File(image.path));
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please grant photo access in app settings'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_selectedImage == null) return _userProfile?.avatarUrl;

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) return null;

      final fileName = 'profile_$userId.jpg';

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return _userProfile?.avatarUrl;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Upload image if selected
      final avatarUrl = await _uploadProfileImage();

      await _userService.updateUserProfile(
        userId: userId,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        avatarUrl: avatarUrl,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        pinCode: _pinCodeController.text.trim().isEmpty
            ? null
            : _pinCodeController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        state: _selectedState,
        age: _ageController.text.trim().isEmpty
            ? null
            : int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
          _selectedImage = null;
        });
        // Reload profile to get updated data
        _loadUserProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppConstants.loginRoute, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildAnimatedField(0, _buildEmailField()),
                          const SizedBox(height: 16),
                          _buildAnimatedField(1, _buildNameField()),
                          const SizedBox(height: 16),
                          _buildAnimatedField(2, _buildPhoneField()),
                          const SizedBox(height: 16),
                          _buildAnimatedField(3, _buildAddressField()),
                          const SizedBox(height: 16),
                          _buildAnimatedField(4, _buildPinCityRow()),
                          const SizedBox(height: 16),
                          _buildAnimatedField(5, _buildStateField()),
                          const SizedBox(height: 16),
                          _buildAnimatedField(6, _buildAgeGenderRow()),
                          const SizedBox(height: 32),
                          _buildAnimatedField(7, _buildSignOutButton()),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    final avatarUrl = _userProfile?.avatarUrl;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xff0c1c2c),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isEditing
              ? Row(
                  key: const ValueKey('save'),
                  children: [
                    TextButton(
                      onPressed: () => setState(() {
                        _isEditing = false;
                        _selectedImage = null;
                        // Reset form values
                        if (_userProfile != null) {
                          _nameController.text = _userProfile!.fullName;
                          _phoneController.text = _userProfile!.phone ?? '';
                          _addressController.text = _userProfile!.address ?? '';
                          _pinCodeController.text = _userProfile!.pinCode ?? '';
                          _cityController.text = _userProfile!.city ?? '';
                          _ageController.text =
                              _userProfile!.age?.toString() ?? '';
                          _selectedState = _userProfile!.state;
                          _selectedGender = _userProfile!.gender;
                        }
                      }),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.urbanist(color: Colors.white70),
                      ),
                    ),
                    _isSaving
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.amber,
                                ),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.check, color: Colors.amber),
                            onPressed: _saveProfile,
                          ),
                  ],
                )
              : IconButton(
                  key: const ValueKey('edit'),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => setState(() => _isEditing = true),
                ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xff0c1c2c),
                const Color(0xff0c1c2c).withOpacity(0.8),
                Colors.grey[50]!,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Avatar with edit overlay
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'profile_avatar',
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color.fromARGB(255, 212, 175, 55),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                : avatarUrl != null && avatarUrl.isNotEmpty
                                ? Image.network(
                                    avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildDefaultAvatar(),
                                  )
                                : _buildDefaultAvatar(),
                          ),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 212, 175, 55),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userProfile?.fullName ?? 'User',
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userProfile?.email ?? '',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xff1a2d40),
      child: const Icon(
        Icons.person,
        size: 50,
        color: Color.fromARGB(255, 212, 175, 55),
      ),
    );
  }

  Widget _buildAnimatedField(int index, Widget child) {
    if (index >= _fadeAnimations.length) return child;

    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(position: _slideAnimations[index], child: child),
    );
  }

  Widget _buildFieldCard({required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: _isEditing
            ? Border.all(
                color: const Color.fromARGB(255, 212, 175, 55).withOpacity(0.3),
              )
            : null,
      ),
      child: child,
    );
  }

  Widget _buildEmailField() {
    return _buildFieldCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff0c1c2c).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.email_outlined, color: Color(0xff0c1c2c)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userProfile?.email ?? '-',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff0c1c2c),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline, size: 18, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return _buildFieldCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff0c1c2c).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_outline, color: Color(0xff0c1c2c)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _isEditing
                ? TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: GoogleFonts.urbanist(color: Colors.grey[600]),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Name is required' : null,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Name',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile?.fullName ?? '-',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0c1c2c),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return _buildFieldCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff0c1c2c).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.phone_outlined, color: Color(0xff0c1c2c)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _isEditing
                ? TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      labelStyle: GoogleFonts.urbanist(color: Colors.grey[600]),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile?.phone ?? '-',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0c1c2c),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return _buildFieldCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff0c1c2c).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Color(0xff0c1c2c),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _isEditing
                ? TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: GoogleFonts.urbanist(color: Colors.grey[600]),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile?.address ?? '-',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0c1c2c),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinCityRow() {
    return Row(
      children: [
        Expanded(
          child: _buildFieldCard(
            child: _isEditing
                ? TextFormField(
                    controller: _pinCodeController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Pin Code',
                      labelStyle: GoogleFonts.urbanist(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.pin_drop_outlined, size: 20),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pin Code',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile?.pinCode ?? '-',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0c1c2c),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFieldCard(
            child: _isEditing
                ? TextFormField(
                    controller: _cityController,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'City',
                      labelStyle: GoogleFonts.urbanist(color: Colors.grey[600]),
                      prefixIcon: const Icon(
                        Icons.location_city_outlined,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'City',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile?.city ?? '-',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0c1c2c),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateField() {
    return _buildFieldCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff0c1c2c).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.map_outlined, color: Color(0xff0c1c2c)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _isEditing
                ? DropdownButtonFormField<String>(
                    value: _selectedState,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'State',
                      labelStyle: GoogleFonts.urbanist(color: Colors.grey[600]),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff0c1c2c),
                    ),
                    items: _indianStates
                        .map(
                          (state) => DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedState = v),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'State',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile?.state ?? '-',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0c1c2c),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGenderRow() {
    return Row(
      children: [
        Expanded(
          child: _buildFieldCard(
            child: _isEditing
                ? TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Age',
                      labelStyle: GoogleFonts.urbanist(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Age',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile?.age?.toString() ?? '-',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0c1c2c),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFieldCard(
            child: _isEditing
                ? DropdownButtonFormField<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      labelStyle: GoogleFonts.urbanist(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.wc_outlined, size: 20),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff0c1c2c),
                    ),
                    items: _genderOptions
                        .map(
                          (g) => DropdownMenuItem(
                            value: g,
                            child: Text(g, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedGender = v),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gender',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile?.gender ?? '-',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0c1c2c),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _signOut,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          'Sign Out',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
