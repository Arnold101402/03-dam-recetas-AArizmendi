import 'package:flutter/material.dart';
import 'package:recetasapp/models/receta.dart';
import 'package:recetasapp/services/recipe_service.dart';
import 'package:recetasapp/widgets/receta_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Receta>> _recetas;

  @override
  void initState() {
    super.initState();
    _recetas = RecipeService().obtenerRecetas();
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
        future: _recetas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final recetas = snapshot.data!;
          return ListView.builder(
            itemCount: recetas.length,
            itemBuilder: (context, i) =>
                RecetaCard(receta: recetas[i], onTap: () {}),
          );
        },
      ),
    );
  }
}
