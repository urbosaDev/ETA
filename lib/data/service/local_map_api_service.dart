import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class LocalMapApiService {
  Future<Map<String, dynamic>> addressToCoordinate({required String query});

  Future<Map<String, dynamic>> keywordToPlace({
    required String query,
    int page,
  });

  Future<Map<String, dynamic>> coordinateToAddress({
    required String longitude,
    required String latitude,
  });
}

class KakaoMapLocalApiService implements LocalMapApiService {
  final http.Client _client;
  final String _baseUrl;
  final String _apiKey;
  static const int _fixedSize = 10;

  KakaoMapLocalApiService({
    required http.Client client,
    required String baseUrl,
    required String apiKey,
  }) : _client = client,
       _baseUrl = baseUrl,
       _apiKey = apiKey;

  @override
  Future<Map<String, dynamic>> addressToCoordinate({
    required String query,
  }) async {
    final uri = Uri.parse('$_baseUrl/v2/local/search/address.json').replace(
      queryParameters: {
        'query': query,
        'page': '1', // 고정
        'size': _fixedSize.toString(),
      },
    );

    final response = await _client.get(
      uri,
      headers: {'Authorization': 'KakaoAK $_apiKey'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('주소 → 좌표 변환 실패: ${response.statusCode}');
    }
  }

  @override
  Future<Map<String, dynamic>> keywordToPlace({
    required String query,
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/v2/local/search/keyword.json').replace(
      queryParameters: {
        'query': query,
        'page': page.toString(),
        'size': _fixedSize.toString(),
      },
    );

    final response = await _client.get(
      uri,
      headers: {'Authorization': 'KakaoAK $_apiKey'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('키워드 장소 검색 실패: ${response.statusCode}');
    }
  }

  @override
  Future<Map<String, dynamic>> coordinateToAddress({
    required String longitude,
    required String latitude,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/v2/local/geo/coord2address.json',
    ).replace(queryParameters: {'x': longitude, 'y': latitude});

    final response = await _client.get(
      uri,
      headers: {'Authorization': 'KakaoAK $_apiKey'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('좌표 → 주소 변환 실패: ${response.statusCode}');
    }
  }
}
