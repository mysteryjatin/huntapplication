import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agent_model.dart';

class AgentsRepository {
  final String baseUrl;

  AgentsRepository({this.baseUrl = 'http://72.61.237.178:8000/api/users/agents/search'});

  /// Search agents. `payload` is optional search filters (sent as POST body).
  Future<Map<String, dynamic>> search({Map<String, dynamic>? payload}) async {
    final url = Uri.parse(baseUrl);
    final body = payload == null ? null : jsonEncode(payload);
    final res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});

    // debug
    print('REQUEST -> Agents search: url=$url body=$body');
    print('RESPONSE -> Agents search: status=${res.statusCode} body=${res.body}');

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      // parse agents list
      final agentsRaw = data['agents'] as List<dynamic>? ?? [];
      final agents = agentsRaw.map((e) => AgentModel.fromJson(e as Map<String, dynamic>)).toList();

      return {
        'agents': agents,
        'total': data['total'],
        'page': data['page'],
        'limit': data['limit'],
        'total_pages': data['total_pages'],
        'has_next': data['has_next'],
        'has_prev': data['has_prev'],
      };
    }
    throw Exception('Failed to search agents: ${res.statusCode} body=${res.body}');
  }
}

