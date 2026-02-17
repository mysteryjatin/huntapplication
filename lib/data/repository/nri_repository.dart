import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nri_query_model.dart';

class NriRepository {
  final String baseUrl;
  NriRepository({this.baseUrl = 'http://72.61.237.178:8000/api/nri-queries'});

  Future<NriQueryModel> submitQuery({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String stateName,
    required String country,
    required String message,
    String? userId,
  }) async {
    final url = Uri.parse(baseUrl + '/');
    final body = jsonEncode({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'state': stateName,
      'country': country,
      'message': message,
      if (userId != null) 'user_id': userId,
    });

    final res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
    // debug
    print('REQUEST -> NRI submit: url=$url body=$body');
    print('RESPONSE -> NRI submit: status=${res.statusCode} body=${res.body}');

    if (res.statusCode == 201 || res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return NriQueryModel.fromJson(json);
    }
    throw Exception('Failed to submit NRI query: ${res.statusCode} body=${res.body}');
  }
}

