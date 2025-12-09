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

  // Ensure we don't double-prefix /api and we always have a single leading slash
  String _normalizePath(String path) {
    var p = path.trim();
    if (p.isEmpty) return '/';
    if (!p.startsWith('/')) p = '/$p';
    if (p.startsWith('/api/')) {
      p = p.substring(4); // remove leading '/api'
    } else if (p == '/api') {
      p = '/';
    }
    return p;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalized = _normalizePath(path);
    return Uri.parse('$apiBaseUrl$normalized').replace(queryParameters: query);
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
    // base already has /api -> this hits /api/health
    return getJson('/health');
  }

  Future<List<dynamic>> getListings({Map<String, dynamic>? query}) async {
    final res = await _client.get(_uri('/listings', query), headers: _headers());
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET /listings failed: ${res.statusCode} ${res.body}');
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
