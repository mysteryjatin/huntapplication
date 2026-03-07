import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hunt_property/models/property.dart';

class PropertyRepository {
  final String baseUrl;

  PropertyRepository({this.baseUrl = 'http://72.61.237.178:8000'});

  Future<Property> fetchProperty(String propertyId) async {
    final trimmedId = propertyId.trim();
    // If ID is empty, hit the collection endpoint; backend returns a list.
    final url = trimmedId.isEmpty
        ? Uri.parse('$baseUrl/api/properties/')
        : Uri.parse('$baseUrl/api/properties/$trimmedId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Debug: print raw API response in console
      // ignore: avoid_print
      print(
          '📥 FETCH PROPERTY [$propertyId] RESPONSE: ${response.statusCode} ${response.body}');

      final decoded = json.decode(response.body);

      Map<String, dynamic>? propertyJson;

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('_id')) {
          propertyJson = decoded;
        } else if (decoded['data'] is Map<String, dynamic>) {
          final inner = decoded['data'] as Map<String, dynamic>;
          if (inner.containsKey('_id')) {
            propertyJson = inner;
          }
        } else if (decoded['properties'] is List &&
            (decoded['properties'] as List).isNotEmpty) {
          final first = (decoded['properties'] as List).first;
          if (first is Map<String, dynamic>) {
            propertyJson = first;
          }
        }
      } else if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) {
          propertyJson = first;
        }
      }

      if (propertyJson == null) {
        throw Exception('Unexpected property response format');
      }

      return Property.fromJson(propertyJson);
    } else {
      throw Exception('Failed to load property (${response.statusCode})');
    }
  }
}

