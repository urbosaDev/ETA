import 'dart:convert';
import 'package:http/http.dart' as http;

class NaverMapApiService {
  final String _baseUrl =
      'https://maps.apigw.ntruss.com/map-geocode/v2/geocode';
  final String clientId;
  final String clientSecret;

  NaverMapApiService({required this.clientId, required this.clientSecret});

  Future<Map<String, dynamic>> geocode({
    required String query,
    int page = 1,
    int count = 10,
    String language = 'kor',
    String? coordinate,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'query': query,
        'page': page.toString(),
        'count': count.toString(),
        'language': language,
        if (coordinate != null) 'coordinate': coordinate,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'X-NCP-APIGW-API-KEY-ID': clientId,
        'X-NCP-APIGW-API-KEY': clientSecret,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('응답 본문: ${response.body}');

      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Geocoding API 요청 실패: ${response.statusCode}');
    }
  }

  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc',
    ).replace(
      queryParameters: {
        'coords': '$longitude,$latitude', // 위도,경도 순서 아님! 꼭 경도,위도
        'orders': 'roadaddr', // 도로명 주소만 받기
        'output': 'json',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'X-NCP-APIGW-API-KEY-ID': clientId,
        'X-NCP-APIGW-API-KEY': clientSecret,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'];
      if (results != null && results.isNotEmpty) {
        final address = results[0]['land']?['addition0']?['value'];
        return address;
      }
    }

    return null; // 실패 시 null
  }
}
