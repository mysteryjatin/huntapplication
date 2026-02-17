import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/loan_eligibility_model.dart';
import '../models/rental_value_model.dart';
import '../models/emi_model.dart';

class FinancialCalculatorsRepository {
  final String baseUrl;

  FinancialCalculatorsRepository({this.baseUrl = 'http://72.61.237.178:8000/api/financial-calculators'});

  Future<LoanEligibilityModel> loanEligibility({
    required int loanRequired,
    required int netIncomePerMonth,
    required int existingLoanCommitments,
    required int loanTenureYears,
    required num rateOfInterest,
  }) async {
    final url = Uri.parse('$baseUrl/loan-eligibility');
    final body = jsonEncode({
      'loan_required': loanRequired,
      'net_income_per_month': netIncomePerMonth,
      'existing_loan_commitments': existingLoanCommitments,
      'loan_tenure_years': loanTenureYears,
      'rate_of_interest': rateOfInterest,
    });

    final res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});

    // Debug logs
    print('REQUEST -> LoanEligibility: url=$url body=$body');
    print('RESPONSE -> LoanEligibility: status=${res.statusCode} body=${res.body}');

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return LoanEligibilityModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to fetch loan eligibility: ${res.statusCode} body=${res.body}');
  }

  Future<RentalValueModel> rentalValue({
    required int propertyValue,
    required num rateOfRent,
    required int years,
  }) async {
    final url = Uri.parse('$baseUrl/rental-value');
    final body = jsonEncode({
      'property_value': propertyValue,
      'rate_of_rent': rateOfRent,
      'years': years,
    });
    final res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});

    // Debug logs
    print('REQUEST -> RentalValue: url=$url body=$body');
    print('RESPONSE -> RentalValue: status=${res.statusCode} body=${res.body}');

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return RentalValueModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to fetch rental value: ${res.statusCode} body=${res.body}');
  }

  Future<EmiModel> emi({
    required int loanAmount,
    required int loanTenureYears,
    required num rateOfInterest,
  }) async {
    final url = Uri.parse('$baseUrl/emi');
    final body = jsonEncode({
      'loan_amount': loanAmount,
      'loan_tenure_years': loanTenureYears,
      'rate_of_interest': rateOfInterest,
    });
    final res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});

    // Debug logs
    print('REQUEST -> EMI: url=$url body=$body');
    print('RESPONSE -> EMI: status=${res.statusCode} body=${res.body}');

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return EmiModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to fetch emi: ${res.statusCode} body=${res.body}');
  }

  // Future value endpoint isn't described in detail; implement a simple passthrough.
  Future<Map<String, dynamic>> futureValue(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/future-value');
    final body = jsonEncode(payload);
    final res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});

    // Debug logs
    print('REQUEST -> FutureValue: url=$url body=$body');
    print('RESPONSE -> FutureValue: status=${res.statusCode} body=${res.body}');

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch future value: ${res.statusCode} body=${res.body}');
  }
}

