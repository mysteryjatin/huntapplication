import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';

import 'package:sms_autofill/sms_autofill.dart';

import 'package:image_picker/image_picker.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/profile_service.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/services/property_service.dart';
import 'package:hunt_property/services/auth_service.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen>
    with CodeAutoFill {
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
  bool _isDeleting = false;
  String? _userId;
  bool _isVerifyingPhone = false;
  bool _isPhoneVerified = false;
  TextEditingController? _otpDialogController;
  String? _deleteReason;
  final TextEditingController _deleteNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    listenForCode();
    _loadProfile();
  }

  @override
  void codeUpdated() {
    final code = this.code;
    if (code == null || code.length < 6) return;
    if (_otpDialogController != null) {
      _otpDialogController!.text = code.substring(0, 6);
    }
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
        
        // Prefer backend data; if some fields missing (like address),
        // fall back to locally cached values so user doesn't lose edits.
        final cachedAddress = await StorageService.getUserAddress();

        setState(() {
          _fullNameController.text = data['full_name']?.toString() ??
              data['name']?.toString() ??
              _fullNameController.text;
          _emailController.text =
              data['email']?.toString() ?? _emailController.text;
          _mobileController.text = data['phone_number']?.toString() ??
              data['phone']?.toString() ??
              _mobileController.text;
          _isPhoneVerified = _mobileController.text.trim().isNotEmpty;

          final addrFromApi = data['address']?.toString();
          if (addrFromApi != null && addrFromApi.isNotEmpty) {
            _addressController.text = addrFromApi;
          } else if (cachedAddress != null && cachedAddress.isNotEmpty) {
            _addressController.text = cachedAddress;
          }
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
      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _mobileController.text.trim();
      final address = _addressController.text.trim();

      // Build profile payload. Phone should ONLY be sent when verified,
      // otherwise keep existing phone on backend and force user to go
      // through the OTP verification flow.
      final profileData = <String, dynamic>{
        'full_name': fullName,
        'name': fullName,
        'email': email,
        'address': address,
        if (_isPhoneVerified && phone.isNotEmpty) ...{
          'phone_number': phone,
          'phone': phone,
        },
        if (_uploadedProfileUrl != null && _uploadedProfileUrl!.isNotEmpty) ...{
          'profile_picture': _uploadedProfileUrl,
          'profilePicture': _uploadedProfileUrl,
        },
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
              final addrFromApi = data['address']?.toString();
              if (addrFromApi != null && addrFromApi.isNotEmpty) {
                _addressController.text = addrFromApi;
              } else {
                _addressController.text = address;
              }

              // Cache address locally so that even if backend ignores it,
              // we can restore it next time.
              StorageService.saveUserAddress(_addressController.text);

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

  Future<void> _deleteAccount() async {
    if (_userId == null || _userId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
      }
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final result = await _profileService.deleteAccount(
        _userId!,
        reason: _deleteReason,
        note: _deleteNoteController.text.trim().isEmpty
            ? null
            : _deleteNoteController.text.trim(),
      );

      setState(() {
        _isDeleting = false;
      });

      if (result['success'] == true) {
        await StorageService.clearAll();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted permanently'),
          ),
        );

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error']?.toString() ?? 'Failed to delete account',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    if (_isDeleting) return;

    _deleteReason = null;
    _deleteNoteController.clear();

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final bool needsNote = _deleteReason == 'changed_mind';
          final bool canDelete = _deleteReason != null &&
              (!needsNote || _deleteNoteController.text.trim().isNotEmpty);

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please select one reason before deleting your account:',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'sold_out',
                      groupValue: _deleteReason,
                      activeColor: const Color(0xFF2FED9A),
                      title: const Text('My property sold out!'),
                      onChanged: (value) {
                        setDialogState(() {
                          _deleteReason = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'rent_out',
                      groupValue: _deleteReason,
                      activeColor: const Color(0xFF2FED9A),
                      title: const Text('My property rent out!'),
                      onChanged: (value) {
                        setDialogState(() {
                          _deleteReason = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'changed_mind',
                      groupValue: _deleteReason,
                      activeColor: const Color(0xFF2FED9A),
                      title: const Text('I have changed my mind (with note)!'),
                      onChanged: (value) {
                        setDialogState(() {
                          _deleteReason = value;
                        });
                      },
                    ),
                    if (needsNote) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _deleteNoteController,
                        maxLines: 3,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Enter note',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Color(0xFF2FED9A), width: 1.5),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'No',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (_isDeleting || !canDelete)
                                ? null
                                : () {
                                    Navigator.pop(dialogContext);
                                    _deleteAccount();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isDeleting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Yes, Delete',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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

  String _getImagePickerErrorMessage(Object error, {required String source}) {
    if (error is PlatformException) {
      final code = error.code.toLowerCase();
      if (code.contains('photo_access_denied') ||
          code.contains('camera_access_denied') ||
          code.contains('permission')) {
        return 'Permission denied. Please allow $source access from iOS Settings.';
      }
      if (code.contains('camera_unavailable')) {
        return 'Camera is unavailable on this device.';
      }
      if (code.contains('invalid_image') || code.contains('no_available_camera')) {
        return 'Unable to open $source. Please try again.';
      }
    }

    if (Platform.isIOS && source == 'camera') {
      return 'Unable to open camera. Please check camera permission in Settings.';
    }
    return 'Unable to open $source. Please try again.';
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

    final sourceLabel = choice == 'camera' ? 'camera' : 'gallery';
    XFile? picked;
    try {
      if (choice == 'camera') {
        picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      } else {
        picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getImagePickerErrorMessage(e, source: sourceLabel))),
        );
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
        // Always fetch latest userId from storage so null _userId ki wajah se
        // image cache miss na ho.
        String? currentUserId = _userId;
        currentUserId ??= await StorageService.getUserId();
        if (currentUserId != null && currentUserId.isNotEmpty) {
          _userId = currentUserId;
          await StorageService.saveTempProfilePicture(currentUserId, url);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image upload failed. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _deleteNoteController.dispose();
    cancel();
    super.dispose();
  }

  bool _canStartPhoneVerification() {
    final phone = _mobileController.text.trim();
    return !_isVerifyingPhone && phone.length == 10;
  }

  Future<void> _startPhoneVerification() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final raw = _mobileController.text.trim();
    if (raw.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter 10 digit mobile number')),
      );
      return;
    }

    final phoneWithCode = '+91$raw';
    setState(() {
      _isVerifyingPhone = true;
    });

    final authService = AuthService();
    try {
      // Use the same OTP API as signup (`/api/auth/request-otp`)
      final otpResult = await authService.requestOtp(phoneWithCode);

      if (otpResult['success'] != true) {
        setState(() {
          _isVerifyingPhone = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                otpResult['error']?.toString() ??
                    'Failed to send verification OTP',
              ),
            ),
          );
        }
        return;
      }

      final otp = await _showOtpDialog();
      if (otp == null || otp.isEmpty) {
        setState(() {
          _isVerifyingPhone = false;
        });
        return;
      }

      // Verify OTP using the same verify endpoint as signup
      final verifyResult = await authService.verifyOtp(
        phoneWithCode,
        otp,
      );

      setState(() {
        _isVerifyingPhone = false;
      });

      if (verifyResult['success'] == true) {
        // OTP is correct; now attach this phone to the current user profile
        final updateResult = await _profileService.updateProfile(_userId!, {
          'phone': phoneWithCode,
          'phone_number': phoneWithCode,
        });

        if (updateResult['success'] == true) {
          setState(() {
            _isPhoneVerified = true;
            _mobileController.text = raw;
          });
          await StorageService.saveUserPhone(phoneWithCode);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phone number verified successfully'),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  updateResult['error']?.toString() ??
                      'OTP verified, but failed to update profile',
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                verifyResult['error']?.toString() ?? 'Invalid or expired OTP',
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isVerifyingPhone = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error verifying phone: $e')),
        );
      }
    }
  }

  Future<String?> _showOtpDialog() async {
    _otpDialogController?.dispose();
    _otpDialogController = TextEditingController();
    final controller = _otpDialogController!;
    int remainingSeconds = 30;
    bool isResending = false;

    final otp = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Timer? timer;

        void startTimer(StateSetter setState) {
          timer?.cancel();
          remainingSeconds = 30;
          timer = Timer.periodic(const Duration(seconds: 1), (t) {
            if (remainingSeconds <= 1) {
              t.cancel();
              setState(() {
                remainingSeconds = 0;
              });
            } else {
              setState(() {
                remainingSeconds--;
              });
            }
          });
        }

        return StatefulBuilder(
          builder: (context, setState) {
            // Start timer the first time this builder runs
            if (remainingSeconds == 30 && timer == null) {
              startTimer(setState);
            }

            Future<void> handleResend() async {
              if (_userId == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not logged in')),
                  );
                }
                return;
              }
              setState(() {
                isResending = true;
              });
              final phoneRaw = _mobileController.text.trim();
              final phoneWithCode = '+91$phoneRaw';
              final authService = AuthService();
              try {
                final result = await authService.profilePhoneRequestOtp(
                  userId: _userId!,
                  phone: phoneWithCode,
                );
                if (result['success'] != true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['error']?.toString() ??
                            'Failed to resend OTP. Please try again.',
                      ),
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP resent successfully'),
                    ),
                  );
                }
                setState(() {
                  isResending = false;
                });
                // Restart timer after resend
                startTimer(setState);
              } catch (e) {
                setState(() {
                  isResending = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error resending OTP: $e'),
                    ),
                  );
                }
              }
            }

            return AlertDialog(
              title: const Text('Enter OTP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: '6 digit OTP',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        remainingSeconds > 0
                            ? 'Resend in ${remainingSeconds}s'
                            : 'Didn\'t receive OTP?',
                        style: const TextStyle(fontSize: 12),
                      ),
                      TextButton(
                        onPressed: (remainingSeconds == 0 && !isResending)
                            ? handleResend
                            : null,
                        child: isResending
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Resend OTP'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final otp = controller.text.trim();
                    if (otp.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter 6 digit OTP'),
                        ),
                      );
                      return;
                    }
                    timer?.cancel();
                    Navigator.of(dialogContext).pop(otp);
                  },
                  child: const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );

    _otpDialogController?.dispose();
    _otpDialogController = null;

    return otp;
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
                  _buildMobileWithVerify(),
                  
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
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed:
                          (_isSaving || _isDeleting) ? null : _showDeleteAccountDialog,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isDeleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                            )
                          : const Text(
                              'Delete Account',
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

  Widget _buildMobileWithVerify() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _mobileController,
                maxLines: 1,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (_) {
                  setState(() {
                    _isPhoneVerified = false;
                  });
                },
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide:
                        BorderSide(color: Color(0xFF2FED9A), width: 2),
                  ),
                  counterText: '',
                  suffixIcon: Icon(
                    Icons.edit,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isPhoneVerified
                ? const Icon(Icons.verified, color: Colors.green)
                : ElevatedButton(
                    onPressed:
                        _canStartPhoneVerification() ? _startPhoneVerification : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      minimumSize: const Size(80, 44),
                    ),
                    child: _isVerifyingPhone
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
          ],
        ),
      ],
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
          keyboardType: label.toLowerCase().contains('mobile') || label.toLowerCase().contains('phone')
              ? TextInputType.phone
              : TextInputType.text,
          inputFormatters: label.toLowerCase().contains('mobile') || label.toLowerCase().contains('phone')
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
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




