import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:hunt_property/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_vaastu_analysis_screen.dart';

class InvalidImageScreen extends StatefulWidget {
  final String imagePath;
  final String? errorMessage;

  const InvalidImageScreen({
    super.key,
    required this.imagePath,
    this.errorMessage,
  });

  @override
  State<InvalidImageScreen> createState() => _InvalidImageScreenState();
}

class _InvalidImageScreenState extends State<InvalidImageScreen> {
  bool _isPickingImage = false;

  Future<void> _pickNewImage(BuildContext context, ImageSource source) async {
    if (!context.mounted || _isPickingImage) return;
    
    setState(() {
      _isPickingImage = true;
    });
    
    final ImagePicker picker = ImagePicker();
    try {
      print('📸 Starting image picker with source: $source');
      
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        print('✅ Image selected: ${image.path}');
        
        if (!context.mounted) return;
        
        // Navigate to AI chat screen with the new image
        // This will trigger the same analysis process as the main upload button:
        // 1. Image validation
        // 2. Direction selection
        // 3. AI analysis
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AiVaastuAnalysisScreen(imagePath: image.path),
          ),
        );
      } else {
        print('❌ No image selected');
        if (mounted) {
          setState(() {
            _isPickingImage = false;
          });
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No image selected'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error picking image: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error picking image: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _showImageSourceDialog(context),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Ai Vaastu Analysis",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🔹 COMBINED CONTAINER (Single Green Border)
            Stack(
              clipBehavior: Clip.none,
              children: [

                /// 🟢 GREEN BORDER CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF5BE0A1), // green border
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [

                      /// ⚠️ WARNING ICON
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          size: 26,
                          color: Color(0xFFFF5252),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 🔴 TITLE
                      const Text(
                        "Image Validation Failed",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF3B30),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// 📝 SUBTITLE
                      Text(
                        widget.errorMessage ??
                            "This image not supported Please update floor plan image",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ❌ INVALID IMAGE
                      Container(
                        height: 170,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF5252),
                            width: 1.6,
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ImageFiltered(
                                imageFilter:
                                ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                child: Image.file(
                                  File(widget.imagePath),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),

                            /// FULL OVERLAY
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/invaild.svg",
                                      height: 34,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Invalid Document",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        "Please upload a clear floor plan image to proceed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// ⬆️ UPLOAD BUTTON
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEAF9FF), Color(0xFFD1D3FB)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFCECCCF),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _isPickingImage
                              ? null
                              : () => _showImageSourceDialog(context),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child:
                                SvgPicture.asset("assets/icons/upload.svg"),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Upload New Image",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.check,
                                      size: 14, color: Color(0xFF3847ED)),
                                  SizedBox(width: 4),
                                  Text(
                                    "CHOOSE CLEAR HOUSE PLAN",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3847ED),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🟡 GANESHA JI – OUTSIDE GREEN BORDER
                Positioned(
                  top: 0,   // ⬅️ clearly outside
                  left: -40,
                  child: Image.asset(
                    'assets/images/ganesha_vaastu_ai.png',
                    width: 40,
                    height: 45,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    print('📋 Showing image source dialog');
    if (!context.mounted) {
      print('❌ Context not mounted, cannot show dialog');
      return;
    }
    
    // Capture the widget's context before showing dialog
    final widgetContext = context;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (dialogContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Image Source",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34F3A3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF34F3A3),
                    ),
                  ),
                  title: const Text(
                    "Choose from Gallery",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: const Text("Select an image from your device"),
                  onTap: () async {
                    print('🖼️ Gallery option tapped');
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    // Small delay to ensure dialog is closed
                    await Future.delayed(const Duration(milliseconds: 300));
                    // Use the captured widget context
                    if (widgetContext.mounted && mounted) {
                      print('📸 Calling _pickNewImage with gallery source');
                      _pickNewImage(widgetContext, ImageSource.gallery);
                    } else {
                      print('❌ Widget not mounted, cannot pick image');
                    }
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34F3A3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF34F3A3),
                    ),
                  ),
                  title: const Text(
                    "Take a Photo",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: const Text("Capture a new image with camera"),
                  onTap: () async {
                    print('📷 Camera option tapped');
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    // Small delay to ensure dialog is closed
                    await Future.delayed(const Duration(milliseconds: 300));
                    // Use the captured widget context
                    if (widgetContext.mounted && mounted) {
                      print('📸 Calling _pickNewImage with camera source');
                      _pickNewImage(widgetContext, ImageSource.camera);
                    } else {
                      print('❌ Widget not mounted, cannot pick image');
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
