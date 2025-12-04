import 'dart:convert';
import 'package:http/http.dart' as http;

class ExercicioService {
  Future<List<dynamic>> getExercicios() async {
    final response = await http.get(
      Uri.parse("https://wger.de/api/v2/exerciseinfo/?language=2&limit=200") 
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data["results"] as List).map((e) {
        return {
          "id": e["id"],
          "descricao": (e["description"] ?? "No description")
              .toString()
              .replaceAll(RegExp(r"<[^>]*>"), ""), // remove HTML
          "muscles": (e["muscles"] as List)
              .map((m) => m["name"] ?? "")
              .toList(), // nomes dos músculos em inglês
        };
      }).toList();
    } else {
      throw Exception(
          "Erro ao buscar exercícios: ${response.statusCode}\n${response.body}");
    }
  }
}