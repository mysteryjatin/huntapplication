import 'package:hunt_property/models/property_models.dart';

class HomeSection {
  final String sectionTitle;
  final String? city;
  final List<Property> properties;

  HomeSection({
    required this.sectionTitle,
    this.city,
    required this.properties,
  });
}

class HomeResponseModel {
  final bool success;
  final HomeSection topSellingProjects;
  final HomeSection recommendYourLocation;
  final HomeSection propertyForRent;

  HomeResponseModel({
    required this.success,
    required this.topSellingProjects,
    required this.recommendYourLocation,
    required this.propertyForRent,
  });

  factory HomeResponseModel.fromMap(Map<String, dynamic> map) {
    final data = map['data'] as Map<String, dynamic>? ?? {};
    Map<String, dynamic> _sec(String key) => (data[key] as Map<String, dynamic>?) ?? {};

    List<Property> _parseProps(Map<String, dynamic> section) {
      final list = section['properties'] as List<dynamic>? ?? [];
      return list.whereType<Map<String, dynamic>>().map((e) => Property.fromJson(e)).toList();
    }

    final top = _sec('top_selling_projects');
    final rec = _sec('recommend_your_location');
    final rent = _sec('property_for_rent');

    return HomeResponseModel(
      success: (map['success'] is bool) ? map['success'] as bool : false,
      topSellingProjects: HomeSection(
        sectionTitle: top['section_title']?.toString() ?? '',
        city: top['city']?.toString(),
        properties: _parseProps(top),
      ),
      recommendYourLocation: HomeSection(
        sectionTitle: rec['section_title']?.toString() ?? '',
        properties: _parseProps(rec),
      ),
      propertyForRent: HomeSection(
        sectionTitle: rent['section_title']?.toString() ?? '',
        properties: _parseProps(rent),
      ),
    );
  }
}

