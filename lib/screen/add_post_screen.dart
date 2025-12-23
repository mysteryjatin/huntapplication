import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/add_post_step2_screen.dart';
import 'package:hunt_property/models/property_models.dart';

class AddPostScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final PropertyDraft? initialDraft;

  const AddPostScreen({super.key, this.onBackPressed, this.initialDraft});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _buildingDescriptionController = TextEditingController();

  late PropertyDraft _draft;

  String _propertyFor = 'Sell'; // Sell or Rent
  String _buildingType = 'Residential'; // Residential, Commercial, Agriculture
  String? _selectedPropertyType; // Selected property type
  
  final int _maxDescriptionLength = 500;
  
  final List<String> _propertyTypes = [
    'House or Kothi',
    'Builder Floor',
    'Villa',
    'Service Apartment',
    'Penthouse',
    'Studio Apartment',
    'Flats',
    'Duplex',
    'Plot/Land',
  ];

  @override
  void initState() {
    super.initState();
    _draft = widget.initialDraft ?? PropertyDraft();

    // Pre-fill controllers if coming back to this step
    _propertyNameController.text = _draft.title;
    _buildingDescriptionController.text = _draft.description;

    _buildingDescriptionController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Save back into draft before disposing
    _draft.title = _propertyNameController.text.trim();
    _draft.description = _buildingDescriptionController.text.trim();

    _propertyNameController.dispose();
    _buildingDescriptionController.dispose();
    super.dispose();
  }

  int get _remainingCharacters {
    return _maxDescriptionLength - _buildingDescriptionController.text.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: widget.onBackPressed ?? () {},
        ),
        title: Column(
          children: [
            Text(
              'User & Property Info',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              'Step 1 of 4',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 24),
            onPressed: widget.onBackPressed ?? () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Info Section
                  _buildSectionTitle('Property Info'),
                  const SizedBox(height: 16),
                  
                  // Property Name Input
                  _buildInputLabel('Property Name'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _propertyNameController,
                    decoration: InputDecoration(
                      hintText: 'Eg 2BHK Apartment for sale',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Property For Section
                  _buildInputLabel('Property For'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildToggleButton('Sell', _propertyFor == 'Sell',
                            () {
                          setState(() => _propertyFor = 'Sell');
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildToggleButton('Rent', _propertyFor == 'Rent',
                            () {
                          setState(() => _propertyFor = 'Rent');
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Building Type Section
                  _buildInputLabel('Builder Type'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildToggleButton('Residential', _buildingType == 'Residential', () {
                          setState(() => _buildingType = 'Residential');
                        }),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildToggleButton('Commercial', _buildingType == 'Commercial', () {
                          setState(() => _buildingType = 'Commercial');
                        }),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildToggleButton('Agricultural', _buildingType == 'Agriculture', () {
                          setState(() => _buildingType = 'Agriculture');
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Property Type Section
                  _buildInputLabel('Property Type'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _propertyTypes.map((type) {
                      final isSelected = _selectedPropertyType == type;
                      return _buildChip(type, isSelected, () {
                        setState(() => _selectedPropertyType = type);
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  
                  // Building Description Section
                  _buildInputLabel('Building Description'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _buildingDescriptionController,
                    maxLines: 5,
                    maxLength: _maxDescriptionLength,
                    decoration: InputDecoration(
                      hintText: 'Enter building description...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.redcolor, width: 1.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.redcolor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      counterText: '',
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '($_remainingCharacters characters left)',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.redcolor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Property Location & Features Section
                  InkWell(
                    onTap: () {
                      // Update draft with current values before navigating
                      _draft
                        ..title = _propertyNameController.text.trim()
                        ..description = _buildingDescriptionController.text.trim()
                        ..transactionType = _propertyFor
                        ..propertyCategory = _buildingType
                        ..propertySubtype = _selectedPropertyType ?? '';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPostStep2Screen(
                            draft: _draft,
                            onBackPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Property Location &',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Features',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 55,
                          height: 55,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

