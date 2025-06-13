// lib/data/service/fcm_service.dart
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class FcmService {
  static const _fcmEndpoint =
      'https://fcm.googleapis.com/v1/projects/what-s-your-eta-1805f/messages:send';
  static const _scope = 'https://www.googleapis.com/auth/firebase.messaging';

  late ServiceAccountCredentials _credentials;
  AccessCredentials? _accessCredentials;

  FcmService() {
    _initCredentials();
  }

  Future<void> _initCredentials() async {
    final jsonString = await rootBundle.loadString(
      'assets/keys/firebase_service_account.json',
    );
    final jsonMap = json.decode(jsonString);
    _credentials = ServiceAccountCredentials.fromJson(jsonMap);
  }

  /// AccessToken 발급
  Future<String> _getAccessToken() async {
    // 만약 기존에 유효한 token 있으면 재사용 가능
    if (_accessCredentials != null &&
        _accessCredentials!.accessToken.hasExpired == false) {
      return _accessCredentials!.accessToken.data;
    }

    final client = http.Client();
    try {
      final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
        _credentials,
        [_scope],
        client,
      );
      _accessCredentials = accessCredentials;
      print('AccessToken 발급됨');
      return accessCredentials.accessToken.data;
    } finally {
      client.close();
    }
  }

  /// FCM 메시지 발송 (단일 기기용 → token 1개 대상)
  Future<void> sendFcmMessage({
    required String targetToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final accessToken = await _getAccessToken();

    final messagePayload = {
      'message': {
        'token': targetToken,
        'notification': {'title': title, 'body': body},
        'data': data ?? {},
      },
    };

    final response = await http.post(
      Uri.parse(_fcmEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(messagePayload),
    );

    if (response.statusCode == 200) {
      print('FCM 메시지 발송 성공!');
    } else {
      print('FCM 메시지 발송 실패: ${response.statusCode} ${response.body}');
    }
  }
}
