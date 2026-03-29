import 'dart:convert';

/// Parses FastAPI / Pydantic validation responses: `{ "detail": "..." }` or
/// `{ "detail": [ { "msg": "...", ... }, ... ] }`.
String? parseFastApiDetailMessage(String responseBody) {
  try {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) return null;
    final detail = decoded['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail.trim();
    }
    if (detail is List) {
      final parts = <String>[];
      for (final item in detail) {
        if (item is Map<String, dynamic>) {
          final msg = item['msg'];
          if (msg is String && msg.trim().isNotEmpty) {
            parts.add(msg.trim());
          }
        }
      }
      if (parts.isNotEmpty) return parts.join('\n');
    }
  } catch (_) {}
  return null;
}
