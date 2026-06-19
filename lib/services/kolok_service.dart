import 'dart:convert';
import '../core/network/api_client.dart';

class KolokService {
  Future<Map<String, dynamic>> createKolok({
    required String name,
    String? address,
  }) async {
    final response = await apiClient.post(
      '/koloks',
      body: {
        'name': name,
        if (address != null && address.isNotEmpty) 'address': address,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body); 
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erreur lors de la création de la colocation');
    }
  }

  Future<Map<String, dynamic>> joinKolok(String joinCode) async {
    final response = await apiClient.post(
      '/koloks/join',
      body: {'joinCode': joinCode},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erreur lors de la tentative de rejoindre');
    }
  }

  Future<Map<String, dynamic>> updateKolok(String id, {String? name, String? address}) async {
    final response = await apiClient.patch(
      '/koloks/$id',
      body: {
        if (name != null) 'name': name,
        if (address != null) 'address': address,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erreur lors de la mise à jour de la colocation');
    }
  }
}