import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home_loan_application_model.dart';

class HomeLoanRepository {
  final String baseUrl;

  HomeLoanRepository({this.baseUrl = 'http://72.61.237.178:8000/api/home-loan-applications'});

  Future<HomeLoanApplicationModel> submitApplication({
    required String loanType,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String userId,
  }) async {
    final url = Uri.parse(baseUrl + '/');
    final body = jsonEncode({
      'loan_type': loanType,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'user_id': userId,
    });

    final res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});

    // Debug
    print('REQUEST -> HomeLoan submit: url=$url body=$body');
    print('RESPONSE -> HomeLoan submit: status=${res.statusCode} body=${res.body}');

    if (res.statusCode == 201 || res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return HomeLoanApplicationModel.fromJson(json);
    }
    throw Exception('Failed to submit home loan application: ${res.statusCode} body=${res.body}');
  }
}

