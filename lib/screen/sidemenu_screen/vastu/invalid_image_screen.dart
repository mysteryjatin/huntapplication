import 'dart:io';
import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 12),
            
            // Invalid Image Card
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFBDF2DE),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Warning Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          size: 28,
                          color: Color(0xFFFF5252),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Error Title
                      const Text(
                        "Image Validation Failed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF5252),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Error Message
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          widget.errorMessage ?? 
                          "This image is not supported. Please update floor plan image.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Invalid Image Preview
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFF5252),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Blurred Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ImageFiltered(
                                imageFilter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Image.file(
                                  File(widget.imagePath),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            
                            // Overlay with Invalid Icon
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5252),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 28,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Invalid Document",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
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
                      
                      // Instruction Text
                      const Text(
                        "Please upload a clear floor plan image to proceed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Decorative Icon (top left)
                Positioned(
                  top: -8,
                  left: -8,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34F3A3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Upload New Image Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF34F3A3),
                    const Color(0xFF2FED9A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34F3A3).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isPickingImage 
                      ? null 
                      : () {
                          print('🔘 Upload button tapped');
                          if (mounted && context.mounted) {
                            _showImageSourceDialog(context);
                          }
                        },
                  child: AnimatedOpacity(
                    opacity: _isPickingImage ? 0.7 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isPickingImage
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.upload_file,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                          const SizedBox(height: 10),
                          Text(
                            _isPickingImage ? "Selecting Image..." : "Upload New Image",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "CHOOSE CLEAR HOUSE PLAN",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
