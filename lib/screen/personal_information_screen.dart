import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/profile_service.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/services/property_service.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final ProfileService _profileService = ProfileService();
  final PropertyService _propertyService = PropertyService();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  String? _uploadedProfileUrl;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _userId = await StorageService.getUserId();
      if (_userId == null) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
        }
        return;
      }

      final result = await _profileService.getProfile(_userId!);
      if (result['success']) {
        final data = result['data'];
        
        // Save user type to storage if available
        final userType = data['user_type']?.toString() ?? 
                        data['userType']?.toString();
        if (userType != null && userType.isNotEmpty) {
          await StorageService.saveUserType(userType);
        }
        
        setState(() {
          _fullNameController.text = data['full_name']?.toString() ?? 
                                     data['name']?.toString() ?? '';
          _emailController.text = data['email']?.toString() ?? '';
          _mobileController.text = data['phone_number']?.toString() ?? 
                                   data['phone']?.toString() ?? '';
          _addressController.text = data['address']?.toString() ?? '';
          // load profile picture if available
          _uploadedProfileUrl = data['profile_picture']?.toString() ?? data['profilePicture']?.toString();
          _pickedImage = null;
          _isLoading = false;
        });
        // If backend didn't return a profile picture, but we have a temp saved one, use it
        if ((_uploadedProfileUrl == null || _uploadedProfileUrl!.isEmpty) && _userId != null) {
          final temp = await StorageService.getTempProfilePicture(_userId!);
          if (temp != null && temp.isNotEmpty) {
            setState(() {
              _uploadedProfileUrl = temp;
              _pickedImage = null;
            });
          }
        } else if (_uploadedProfileUrl != null && _uploadedProfileUrl!.isNotEmpty && _userId != null) {
          // backend has the picture saved; remove any temp cache
          await StorageService.removeTempProfilePicture(_userId!);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Failed to load profile')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final profileData = {
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_number': _mobileController.text.trim(),
        'address': _addressController.text.trim(),
        if (_uploadedProfileUrl != null) 'profile_picture': _uploadedProfileUrl,
      };

      final result = await _profileService.updateProfile(_userId!, profileData);
      
      setState(() {
        _isSaving = false;
      });

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Information saved successfully!')),
          );
          // Update local state from returned data when available, otherwise
          // keep the current preview/uploaded image (so user doesn't lose the image).
          final data = result['data'];
          if (data is Map<String, dynamic>) {
            setState(() {
              _fullNameController.text = data['full_name']?.toString() ??
                  data['name']?.toString() ??
                  _fullNameController.text;
              _emailController.text =
                  data['email']?.toString() ?? _emailController.text;
              _mobileController.text = data['phone_number']?.toString() ??
                  data['phone']?.toString() ??
                  _mobileController.text;
              _addressController.text =
                  data['address']?.toString() ?? _addressController.text;

              // Only update uploaded profile URL if backend returned one.
              final returnedPic = data['profile_picture']?.toString() ??
                  data['profilePicture']?.toString();
              if (returnedPic != null && returnedPic.isNotEmpty) {
                _uploadedProfileUrl = returnedPic;
                _pickedImage = null;
              }
            });
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Failed to save profile')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildProfileImageWidget() {
    // Priority: picked local image -> uploaded URL -> placeholder asset
    if (_pickedImage != null) {
      return Image.file(
        File(_pickedImage!.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderAvatar(),
      );
    }

    if (_uploadedProfileUrl != null && _uploadedProfileUrl!.isNotEmpty) {
      String imageUrl = _uploadedProfileUrl!;
      if (imageUrl.startsWith('/')) {
        imageUrl = '${PropertyService.baseUrl}$imageUrl';
      }
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderAvatar(),
      );
    }

    return _placeholderAvatar();
  }

  Widget _placeholderAvatar() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.grey,
      ),
    );
  }

  Future<void> _onEditPhotoTap() async {
    final choice = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(null),
              ),
            ],
          ),
        );
      },
    );

    if (choice == null) return;

    XFile? picked;
    try {
      if (choice == 'camera') {
        picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      } else {
        picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image pick error: $e')));
      }
      return;
    }

    if (picked == null) return;

    setState(() {
      _pickedImage = picked;
      _uploadedProfileUrl = null; // reset until upload completes
    });

    // Upload immediately and save returned URL for profile update
    try {
      final file = File(picked.path);
      final url = await _propertyService.uploadImage(file);
      if (url != null && url.isNotEmpty) {
        setState(() {
          _uploadedProfileUrl = url;
        });
        // persist temp url so it survives navigation if backend hasn't saved it yet
        if (_userId != null && _userId!.isNotEmpty) {
          await StorageService.saveTempProfilePicture(_userId!, url);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Green Header
          _buildHeader(context),
          
          // Form Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2FED9A)),
                    ),
                  )
                : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  
                  // Profile Picture with Edit Icon
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: ClipOval(
                          child: _buildProfileImageWidget(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: GestureDetector(
                            onTap: _onEditPhotoTap,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Full Name Field
                  _buildTextField(
                    label: 'Full Name',
                    controller: _fullNameController,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Email ID Field
                  _buildTextField(
                    label: 'Email ID',
                    controller: _emailController,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Mobile Number Field
                  _buildTextField(
                    label: 'Mobile Number',
                    controller: _mobileController,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Address Field
                  _buildTextField(
                    label: 'Address',
                    controller: _addressController,
                    maxLines: 2,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2FED9A),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2FED9A), width: 2),
            ),
            suffixIcon: Icon(
              Icons.edit,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}




