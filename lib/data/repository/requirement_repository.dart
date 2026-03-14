import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/requirement_model.dart';

class RequirementRepository {
  final String baseUrl;
  RequirementRepository({this.baseUrl = 'http://72.61.237.178:8000/api/requirements'});

  Future<RequirementModel> submitRequirement({
    required String iam,
    required String want,
    required String name,
    required String email,
    required String mobile,
    required String propertyType,
    required String propertyCity,
    required String bhk,
    required num minPrice,
    required num maxPrice,
  }) async {
    final url = Uri.parse(baseUrl + '/');
    final body = jsonEncode({
      'iam': iam,
      'want': want,
      'name': name,
      'email': email,
      'mobile': mobile,
      'property_type': propertyType,
      'property_city': propertyCity,
      'bhk': bhk,
      'min_price': minPrice,
      'max_price': maxPrice,
    });

    final res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
    // debug
    print('REQUEST -> Requirement submit: url=$url body=$body');
    print('RESPONSE -> Requirement submit: status=${res.statusCode} body=${res.body}');

    if (res.statusCode == 201 || res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return RequirementModel.fromJson(json);
    }
    throw Exception('Failed to submit requirement: ${res.statusCode} body=${res.body}');
  }
}

