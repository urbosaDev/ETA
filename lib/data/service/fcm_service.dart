import 'dart:convert';
import 'package:http/http.dart' as http;

class FcmService {
  final String functionUrl;

  FcmService({required this.functionUrl});

  Future<void> sendFcmMessages({
    required List<Map<String, String>> targetTokens,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final response = await http.post(
      Uri.parse(functionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tokens': targetTokens,
        'title': title,
        'body': body,
        'data': data,
      }),
    );

    if (response.statusCode == 200) {
      print('FCM 발송 성공');
    } else {
      print('FCM 발송 실패: ${response.statusCode} ${response.body}');
    }
  }
}
