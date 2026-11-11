import 'package:flutter/material.dart';
import 'package:recetasapp/data/recetas_db.dart';
import 'package:recetasapp/models/receta.dart';
import 'package:recetasapp/models/resena.dart';
import 'package:recetasapp/screens/resena_screen.dart';

class DetalleRecetaScreen extends StatefulWidget {
  final Receta receta;

  const DetalleRecetaScreen({super.key, required this.receta});

  @override
  State<DetalleRecetaScreen> createState() => _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState extends State<DetalleRecetaScreen> {
  // --- Variables de estado adaptadas de HomeScreen ---
  final _db = RecetasDb.instancia;
  List<Resena> _resenas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // Pide las reseñas de esta receta a la bd y actualiza la pantalla
  Future<void> _cargar() async {
    final lista = await _db.obtenerPorReceta(widget.receta.id);
    if (!mounted) return;
    setState(() {
      _resenas = lista;
      _cargando = false;
    });
  }

  Future<void> _abrirFormulario(Resena? existente) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioResenaScreen(
          recetaId: widget.receta.id,
          resena: existente,
        ),
      ),
    );

    if (guardado == true) {
      await _cargar();
    }
  }

  Future<void> _confirmarEliminar(Resena resena) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar reseña'),
        content: Text('¿Eliminar la reseña de ${resena.autor}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    await _db.eliminar(resena.id!);
    await _cargar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reseña eliminada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de la receta")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(14),
            child: Image.network(
              receta.imagenUrl,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Image.asset(
                "assets/images/plato-placeholder.jpg",
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: [
              Chip(label: Text('${receta.tiempoTotal} min')),
              Chip(label: Text(receta.dificultad)),
              Chip(label: Text(receta.cocina)),
              Chip(label: Text('${receta.calorias} kcal')),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Ingredientes: ",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.ingredientes.map(
            (ingrediente) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Color.fromARGB(255, 200, 101, 246)),
                  const SizedBox(height: 8),
                  Expanded(child: Text(ingrediente))
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Preparación: ",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.instrucciones.asMap().entries.map(
            (entrada) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color.fromARGB(255, 108, 41, 121),
                    child: Text(
                      '${entrada.key + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entrada.value))
                ],
              ),
            ),
          ),

          // --- BOTÓN PARA AGREGAR RESEÑA Y LISTADO INFERIOR ---
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _abrirFormulario(null),
            icon: const Icon(Icons.add),
            label: const Text('Dejar una reseña'),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Reseñas (${_resenas.length}):',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _cuerpo(),
        ],
      ),
    );
  }

  // Adaptado de _cuerpo() en HomeScreen
  Widget _cuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_resenas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'Aún no hay reseñas.\nToca "Dejar una reseña" para agregar la primera.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _resenas.length,
      itemBuilder: (context, i) {
        final f = _resenas[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            onTap: () => _abrirFormulario(f),
            title: Text(
              '"${f.resena}"',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            subtitle: Text('- ${f.autor}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar',
              onPressed: () => _confirmarEliminar(f),
            ),
          ),
        );
      },
    );
  }
}