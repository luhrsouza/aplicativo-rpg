import 'dart:convert';
import 'package:http/http.dart' as http;

class DndApiService {
  static const String _baseUrl = 'https://www.dnd5eapi.co/api';

  Future<List<String>> fetchClasses() async {
    try {
      final url = Uri.parse('$_baseUrl/classes');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];

        return results.map<String>((item) => item['name'] as String).toList();
      } else {
        throw Exception('Falha ao carregar classes da API');
      }
    } catch (e) {
      print('Erro na API D&D: $e');
      return ['Guerreiro', 'Mago', 'Ladino (Offline)'];
    }
  }
}