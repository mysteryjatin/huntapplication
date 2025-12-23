import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/property_service.dart';
import 'package:hunt_property/models/property_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/cubit/auth_cubit.dart';
import 'package:image_picker/image_picker.dart';

class AddPostStep4Screen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final PropertyDraft draft;

  const AddPostStep4Screen({super.key, required this.draft, this.onBackPressed});

  @override
  State<AddPostStep4Screen> createState() => _AddPostStep4ScreenState();
}

class _AddPostStep4ScreenState extends State<AddPostStep4Screen> {
  final PropertyService _propertyService = PropertyService();
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _pickedImages = [];

  String _selectedCategory = 'Exterior View';

  final List<String> _categories = [
    'Exterior View',
    'Living room',
    'Bedrooms',
    'Bathrooms',
    'Kitchen',
    'Floor Plan',
    'Master plan',
    'Location',
    'MapOt',
  ];

  String? _coverImage = "cover";

  final List<String> demoImages = [
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400',
    'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=400',
    'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=400',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400',
    'https://images.unsplash.com/photo-1600573472550-8090b5e0745e?w=400',
    'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=400',
    'https://images.unsplash.com/photo-1600566753151-384129cf4e3e?w=400',
  ];

  // -----------------------------
  Future<void> _uploadImage() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _pickedImages.addAll(images);
        });
      }
    } catch (_) {
      // Ignore picker errors for now
    }
  }

  void _removeImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  void _chooseCover() {
    setState(() {
      _coverImage = "cover";
    });
  }

  void _removeCover() {
    setState(() {
      _coverImage = null;
    });
  }
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _topBar(),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Photos"),
                    const SizedBox(height: 20),

                    _categoryTabs(),

                    const SizedBox(height: 24),
                    _uploadTitle(),
                    const SizedBox(height: 16),

                    _uploadBox(),
                    const SizedBox(height: 16),

                    _uploadRules(),
                    const SizedBox(height: 20),

                    _uploadedImagesGrid(),
                    const SizedBox(height: 24),

                    _coverPictureTitle(),
                    const SizedBox(height: 14),

                    _chooseCoverButton(),
                    const SizedBox(height: 16),

                    _coverPreview(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          _submitButton(),
        ],
      ),
    );
  }

  // ------------------ UI COMPONENTS ------------------

  AppBar _topBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        onPressed: widget.onBackPressed ?? () {},
      ),
      title: Column(
        children: [
          Text("Photos",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
          Text("Step 4 of 4",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textLight,
              )),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, size: 24, color: Colors.black),
          onPressed: widget.onBackPressed ?? () {},
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
              color: AppColors.primaryColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }

  Widget _categoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),

                // GREEN UNDERLINE EXACTLY LIKE SCREENSHOT
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  width: selected ? 35 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _uploadTitle() {
    return Text("Upload Images",
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600));
  }

  Widget _uploadBox() {
    return GestureDetector(
      onTap: _uploadImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_photo_alternate,
                  size: 38, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 12),
            Text("Upload photo and get upto",
                style: GoogleFonts.poppins(fontSize: 14)),
            Text("5X RESPONSE",
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _uploadRules() {
    return Text(
      "Accepted formats are .jpg, .gif, .bmp & .png. Maximum size allowed is 4 MB.\nMinimum dimension allowed 600×400 Pixel",
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
    );
  }

  Widget _uploadedImagesGrid() {
    if (_pickedImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pickedImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(_pickedImages[index].path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _coverPictureTitle() {
    return Text("Add Cover Picture",
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600));
  }

  Widget _chooseCoverButton() {
    return GestureDetector(
      onTap: _chooseCover,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Text("Choose Cover Picture",
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _coverPreview() {
    if (_coverImage == null || _pickedImages.isEmpty) return const SizedBox();

    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: DecorationImage(
              image: FileImage(File(_pickedImages.first.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeCover,
            child: Container(
              width: 32,
              height: 32,
              decoration:
              const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        )
      ],
    );
  }

  Widget _submitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmitProperty,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text("Submit Property",
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<void> _handleSubmitProperty() async {
    setState(() {
      _isSubmitting = true;
    });

    // NOTE:
    // Backend expects each item in "images" to be an object/dictionary,
    // not a plain string. Our current UI only has local image files and
    // we don't yet have an upload endpoint or agreed JSON shape for images.
    // To avoid 422 validation errors, we temporarily send an empty list for
    // "images" and only save the property metadata. When the backend image
    // model / upload API is ready, we can wire picked images accordingly.
    widget.draft.imageUrls = [];

    // Get logged in user id from AuthCubit, if available
    String? ownerId;
    final authState = context.read<AuthCubit>().state;
    if (authState is SignupSuccess) {
      ownerId = authState.user.id;
    }

    final payload = widget.draft.toApiPayload(ownerId: ownerId);

    final result = await _propertyService.createProperty(payload);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property created successfully'),
        ),
      );
      // Navigate to Home after successful post
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      final error = result['error']?.toString() ?? 'Failed to create property';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    }
  }
}
