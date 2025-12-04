import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiClient {
  final http.Client _client;
  String? _accessToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${_accessToken!}';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('$apiBaseUrl$path').replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> getJson(String path, {Map<String, dynamic>? query}) async {
    final res = await _client.get(_uri(path, query), headers: _headers());
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postJson(String path, {Map<String, dynamic>? body}) async {
    final res = await _client.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> health() async {
    return getJson('/health');
  }

  Future<List<dynamic>> getListings({Map<String, dynamic>? query}) async {
    final res = await _client.get(_uri('/api/listings', query), headers: _headers());
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET /api/listings failed: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body);
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List<dynamic>;
    return [];
  }

  void close() {
    _client.close();
  }
}
