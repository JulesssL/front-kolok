import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final http.Client _client = http.Client();
  final storage = const FlutterSecureStorage();
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _handleError(http.Response response) {
    if (response.statusCode == 401) {
      storage.delete(key: 'jwt_token');
      throw Exception('Session expirée');
    }
    if (response.statusCode >= 400) {
      throw Exception('Erreur API: ${response.statusCode} - ${response.body}');
    }
  }

  Future<http.Response> get(String endpoint) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    _handleError(response);
    return response;
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
    _handleError(response);
    return response;
  }

  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
    _handleError(response);
    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    _handleError(response);
    return response;
  }

  Future<http.Response> uploadMultipart(String endpoint, String filePath, String fileField) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    
    final headers = await _getHeaders();
    request.headers.addAll(headers);
    request.headers.remove('Content-Type'); // Let http client set the correct multipart content type
    
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    _handleError(response);
    return response;
  }
}

final apiClient = ApiClient();
