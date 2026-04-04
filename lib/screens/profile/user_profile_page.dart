import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamventz/config/supabase_config.dart';
import 'package:dreamventz/models/user_model.dart';
import 'package:dreamventz/services/user_service.dart';
import 'package:dreamventz/utils/constants.dart';
import 'package:dreamventz/screens/wishlist/wishlist_page.dart';
import 'package:dreamventz/screens/history/history_page.dart';
import 'package:dreamventz/screens/orders/orders_page.dart';

class UserProfilePage extends StatefulWidget {
  final bool startInEditMode;

  const UserProfilePage({super.key, this.startInEditMode = false});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  UserModel? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  File? _selectedImage;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
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
    _isEditing = widget.startInEditMode;
    _initControllers();
    _loadUserProfile();
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _pinCodeController = TextEditingController();
    _cityController = TextEditingController();
    _ageController = TextEditingController();
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
          _emailController.text = _userProfile!.email;
          _addressController.text = _userProfile!.address ?? '';
          _pinCodeController.text = _userProfile!.pinCode ?? '';
          _cityController.text = _userProfile!.city ?? '';
          _ageController.text = _userProfile!.age?.toString() ?? '';
          _selectedState = _userProfile!.state;
          _selectedGender = _userProfile!.gender;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
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
        setState(() => _selectedImage = File(image.path));
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please grant photo access in app settings'),
            action: SnackBarAction(label: 'Settings', onPressed: () => openAppSettings()),
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
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));

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

      final avatarUrl = await _uploadProfileImage();

      await _userService.updateUserProfile(
        userId: userId,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        avatarUrl: avatarUrl,
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        pinCode: _pinCodeController.text.trim().isEmpty ? null : _pinCodeController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        state: _selectedState,
        age: _ageController.text.trim().isEmpty ? null : int.tryParse(_ageController.text.trim()),
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
        _loadUserProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _selectedImage = null;
      if (_userProfile != null) {
        _nameController.text = _userProfile!.fullName;
        _phoneController.text = _userProfile!.phone ?? '';
        _emailController.text = _userProfile!.email;
        _addressController.text = _userProfile!.address ?? '';
        _pinCodeController.text = _userProfile!.pinCode ?? '';
        _cityController.text = _userProfile!.city ?? '';
        _ageController.text = _userProfile!.age?.toString() ?? '';
        _selectedState = _userProfile!.state;
        _selectedGender = _userProfile!.gender;
      }
    });
  }

  Future<void> _signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppConstants.loginRoute, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F3F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _isEditing ? _cancelEdit : () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Your Profile' : 'Your Profile',
          style: GoogleFonts.urbanist(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: _isEditing
            ? [
                _isSaving
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: _saveProfile,
                        child: Text(
                          'Save',
                          style: GoogleFonts.urbanist(
                            color: const Color(0xFFE53935),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
              ]
            : null,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEditing
              ? _buildEditView()
              : _buildOverviewView(),
    );
  }

  // ─── OVERVIEW VIEW ──────────────────────────────────────────────────────────

  Widget _buildOverviewView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildProfileCard(),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: 'My Account',
            items: [
              _SectionItem(
                  icon: Icons.person_outline, 
                  label: 'Personal Info',
                  trailing: _userProfile?.fullName ?? 'Not set',
                  isIncomplete: _userProfile?.fullName == null || _userProfile!.fullName.isEmpty,
                  onTap: () => setState(() => _isEditing = true)
              ),
              _SectionItem(
                  icon: Icons.phone_outlined, 
                  label: 'Mobile Number',
                  trailing: _userProfile?.phone ?? 'Not set',
                  isIncomplete: _userProfile?.phone == null || _userProfile!.phone!.isEmpty,
                  onTap: () => setState(() => _isEditing = true)
              ),
              _SectionItem(
                  icon: Icons.location_on_outlined, 
                  label: 'Address',
                  trailing: _userProfile?.city ?? 'Not set',
                  isIncomplete: _userProfile?.city == null || _userProfile!.city!.isEmpty,
                  onTap: () => setState(() => _isEditing = true)
              ),
              _SectionItem(
                  icon: Icons.wc_outlined, 
                  label: 'Gender',
                  trailing: _userProfile?.gender ?? 'Not set',
                  isIncomplete: _userProfile?.gender == null || _userProfile!.gender!.isEmpty,
                  onTap: () => setState(() => _isEditing = true)
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: 'Preferences',
            items: [
              _SectionItem(icon: Icons.favorite_border, label: 'Wishlist', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage(refreshSignal: 0)))),
              _SectionItem(icon: Icons.inventory_2_outlined, label: 'My Orders', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersPage()))),
              _SectionItem(icon: Icons.history, label: 'Order History', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()))),
              _SectionItem(icon: Icons.notifications_outlined, label: 'Notifications'),
              _SectionItem(icon: Icons.lock_outline, label: 'Privacy & Security'),
              _SectionItem(icon: Icons.help_outline, label: 'Help & Support'),
              _SectionItem(icon: Icons.info_outline, label: 'About'),
            ],
          ),
          const SizedBox(height: 12),
          _buildSignOutTile(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final avatarUrl = _userProfile?.avatarUrl;
    final name = _userProfile?.fullName ?? 'User';
    final email = _userProfile?.email ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFCDD9F0),
              ),
              child: ClipOval(
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : avatarUrl != null && avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initials,
                                style: GoogleFonts.urbanist(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF4A7DC8),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initials,
                              style: GoogleFonts.urbanist(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4A7DC8),
                              ),
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 16),
            // Name + email + edit link
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _isEditing = true),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Edit profile',
                          style: GoogleFonts.urbanist(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE53935),
                          ),
                        ),
                        const Icon(Icons.arrow_right, size: 18, color: Color(0xFFE53935)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<_SectionItem> items}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with left red accent
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Items
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (i > 0)
                  Divider(height: 1, indent: 56, endIndent: 16, color: Colors.grey[100]),
                _buildListTile(item),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildListTile(_SectionItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 20, color: Colors.grey[700]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (item.trailing != null)
              Text(
                item.trailing!,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: item.isIncomplete ? FontWeight.bold : FontWeight.normal,
                  color: item.isIncomplete ? const Color(0xFFE53935) : Colors.grey[500],
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: _signOut,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout, size: 20, color: Colors.red[600]),
              ),
              const SizedBox(width: 14),
              Text(
                'Sign Out',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── EDIT VIEW ───────────────────────────────────────────────────────────────

  Widget _buildEditView() {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildEditAvatar(),
                const SizedBox(height: 24),
                _buildEditCard(children: [
                  _buildOutlinedField(
                    controller: _nameController,
                    label: 'Name',
                    keyboardType: TextInputType.name,
                    validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildMobileField(),
                  const SizedBox(height: 16),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildAddressField(),
                  const SizedBox(height: 16),
                  _buildPinCityRow(),
                  const SizedBox(height: 16),
                  _buildStateDropdown(),
                  const SizedBox(height: 16),
                  _buildGenderDropdown(),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // Bottom Update Profile button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildUpdateButton(),
        ),
      ],
    );
  }

  Widget _buildEditAvatar() {
    final avatarUrl = _userProfile?.avatarUrl;
    final name = _userProfile?.fullName ?? 'U';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFCDD9F0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
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
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(initials,
                              style: GoogleFonts.urbanist(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF4A7DC8))),
                          ),
                        )
                      : Center(
                          child: Text(initials,
                            style: GoogleFonts.urbanist(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF4A7DC8))),
                        ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
              ],
            ),
            child: Icon(Icons.edit, size: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildEditCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildOutlinedField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: GoogleFonts.urbanist(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.urbanist(color: Colors.grey[500], fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4A7DC8), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildFieldWithChange({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = true,
  }) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: GoogleFonts.urbanist(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.urbanist(color: Colors.grey[500], fontSize: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF4A7DC8), width: 1.5),
            ),
            contentPadding: const EdgeInsets.only(left: 16, right: 80, top: 14, bottom: 14),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        Positioned(
          right: 12,
          child: GestureDetector(
            onTap: () {
              // This is a placeholder for change flow (phone/email change via OTP, etc.)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Change $label feature coming soon')),
              );
            },
            child: Text(
              'CHANGE',
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE53935),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileField() {
    return _buildFieldWithChange(
      controller: _phoneController,
      label: 'Mobile',
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildEmailField() {
    return _buildFieldWithChange(
      controller: _emailController,
      label: 'Email',
      readOnly: true,
    );
  }

  Widget _buildAddressField() {
    return _buildOutlinedField(
      controller: _addressController,
      label: 'Address',
      maxLines: 2,
    );
  }

  Widget _buildPinCityRow() {
    return Row(
      children: [
        Expanded(
          child: _buildOutlinedField(
            controller: _pinCodeController,
            label: 'Pin Code',
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOutlinedField(
            controller: _cityController,
            label: 'City',
          ),
        ),
      ],
    );
  }

  Widget _buildStateDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedState,
      isExpanded: true,
      style: GoogleFonts.urbanist(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'State',
        labelStyle: GoogleFonts.urbanist(color: Colors.grey[500], fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4A7DC8), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _indianStates.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
      onChanged: (v) => setState(() => _selectedState = v),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      isExpanded: true,
      style: GoogleFonts.urbanist(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: GoogleFonts.urbanist(color: Colors.grey[500], fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4A7DC8), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (v) => setState(() => _selectedGender = v),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F7),
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSaving ? Colors.grey[300] : const Color(0xFF0c1c2c),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'Update profile',
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// Helper data class for section items
class _SectionItem {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  final bool isIncomplete;

  _SectionItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.isIncomplete = false,
  });
}
