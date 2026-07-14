import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supervisa_task_manager/models/pokemon.dart';

class PokeApiServices {
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  Future<Pokemon> getPokemon(String name) async {
    final uri = Uri.parse('$_baseUrl/$name');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokemon: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Pokemon.fromJson(json);
  }
}
