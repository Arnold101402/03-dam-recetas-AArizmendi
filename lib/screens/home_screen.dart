import 'package:flutter/material.dart';
import 'package:recetasapp/models/receta.dart';
import 'package:recetasapp/screens/detalle_receta_screen.dart';
import 'package:recetasapp/services/recipe_service.dart';
import 'package:recetasapp/widgets/receta_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeService _recipeService = RecipeService();
  late Future<List<Receta>> _futureRecetas;

  @override
  void initState() {
    super.initState();
    _futureRecetas = _recipeService.obtenerRecetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 110, 90, 117),
      appBar: AppBar(
        title: const Text('Recetas del Mayab'),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 244, 241, 241),
        ),
        backgroundColor: const Color.fromARGB(255, 113, 27, 118),
      ),
      body: FutureBuilder<List<Receta>>(
        future: _futureRecetas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final recetas = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: recetas.length,
            itemBuilder: (context, index) {
              return RecetaCard(
                receta: recetas[index],
                onTap: () async {
                  // PARTE AGREGADA INICIA AQUÍ
                  final bool? esFavorita = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetalleRecetaScreen(receta: recetas[index]),
                    ), // MaterialPageRoute
                  );
                }, // PARTE AGREGADA TERMINA AQUÍ
              ); // RecetaCard
            },
          );
        },
      ),
    );
  }
}
