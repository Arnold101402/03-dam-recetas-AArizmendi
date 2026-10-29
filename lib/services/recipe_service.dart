import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recetasapp/models/receta.dart';

class RecipeService {
  static const String _baseUrl = 'https://dummyjson.com/recipes';

  Future<List<Receta>> obtenerRecetas() async {
    final Uri url = Uri.parse(_baseUrl);
    final http.Response respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final Map<String, dynamic> datos = jsonDecode(respuesta.body);
      final List<dynamic> ListaRecetas = datos['recipes'];
      print(ListaRecetas);
      return ListaRecetas
      .map((RecetaJson) => Receta.fromJson(RecetaJson))
      .toList(); 
    } else {
      throw Exception('Error al cargar recetas: ${respuesta.statusCode}');
    }
  }
}