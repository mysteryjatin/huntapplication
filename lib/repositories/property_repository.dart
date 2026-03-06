import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hunt_property/models/property.dart';

class PropertyRepository {
  final String baseUrl;

  PropertyRepository({this.baseUrl = 'http://72.61.237.178:8000'});

  Future<Property> fetchProperty(String propertyId) async {
    final url = Uri.parse('$baseUrl/api/properties/$propertyId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Debug: print raw API response in console
      // ignore: avoid_print
      print(
          '📥 FETCH PROPERTY [$propertyId] RESPONSE: ${response.statusCode} ${response.body}');

      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      return Property.fromJson(data);
    } else {
      throw Exception('Failed to load property (${response.statusCode})');
    }
  }
}

