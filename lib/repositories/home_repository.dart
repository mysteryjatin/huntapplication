import 'package:hunt_property/models/home_models.dart';
import 'package:hunt_property/models/property_models.dart';
import 'package:hunt_property/services/property_service.dart';

class HomeRepository {
  final PropertyService service;
  HomeRepository({PropertyService? service}) : service = service ?? PropertyService();

  /// Fetch home sections from backend and convert to HomeResponseModel
  Future<HomeResponseModel> fetchHomeSections({
    String city = 'Chennai',
    String? userId,
    int limit = 10,
    String? transactionType,
    String? propertyCategory,
  }) async {
    final resp = await service.getHomeSections(
      city: city,
      userId: userId,
      limit: limit,
      transactionType: transactionType,
      propertyCategory: propertyCategory,
    );
    if (resp['success'] == true && resp['sections'] is Map<String, dynamic>) {
      final sections = resp['sections'] as Map<String, dynamic>;
      List<Property> _list(dynamic v) {
        if (v is List<Property>) return v;
        if (v is List) return v.whereType<Property>().toList();
        return <Property>[];
      }

      final top = sections['top_selling_projects'] as Map<String, dynamic>? ?? {};
      final rec = sections['recommend_your_location'] as Map<String, dynamic>? ?? {};
      final rent = sections['property_for_rent'] as Map<String, dynamic>? ?? {};

      return HomeResponseModel(
        success: true,
        topSellingProjects: HomeSection(
          sectionTitle: top['section_title']?.toString() ?? '',
          city: top['city']?.toString(),
          properties: _list(top['properties']),
        ),
        recommendYourLocation: HomeSection(
          sectionTitle: rec['section_title']?.toString() ?? '',
          properties: _list(rec['properties']),
        ),
        propertyForRent: HomeSection(
          sectionTitle: rent['section_title']?.toString() ?? '',
          properties: _list(rent['properties']),
        ),
      );
    }
    // Return empty structure on failure
    return HomeResponseModel(
      success: false,
      topSellingProjects: HomeSection(sectionTitle: '', properties: []),
      recommendYourLocation: HomeSection(sectionTitle: '', properties: []),
      propertyForRent: HomeSection(sectionTitle: '', properties: []),
    );
  }
}

