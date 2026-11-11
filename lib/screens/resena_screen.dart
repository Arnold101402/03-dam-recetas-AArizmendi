import 'package:flutter/material.dart';
import 'package:recetasapp/data/recetas_db.dart';
import 'package:recetasapp/models/resena.dart';

class FormularioResenaScreen extends StatefulWidget {
  final int recetaId;
  final Resena? resena; // null = nueva, con valor = editar

  const FormularioResenaScreen({
    super.key,
    required this.recetaId,
    this.resena,
  });

  @override
  State<FormularioResenaScreen> createState() => _FormularioResenaScreenState();
}

class _FormularioResenaScreenState extends State<FormularioResenaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _resenaCtrl;
  late final TextEditingController _autorCtrl;
  bool get _esEdicion => widget.resena != null;

  @override
  void initState() {
    super.initState();
    _resenaCtrl = TextEditingController(text: widget.resena?.resena ?? '');
    _autorCtrl = TextEditingController(text: widget.resena?.autor ?? '');
  }

  @override
  void dispose() {
    _resenaCtrl.dispose();
    _autorCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final resena = Resena(
      id: widget.resena?.id,
      recetaId: widget.recetaId,
      resena: _resenaCtrl.text.trim(),
      autor: _autorCtrl.text.trim(),
    );
    if (_esEdicion) {
      await RecetasDb.instancia.actualizar(resena);
    } else {
      await RecetasDb.instancia.insert(resena);
    }
    if (!mounted) return;
    Navigator.pop(context, true); // avisa que se guardó algo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar reseña' : 'Nueva reseña'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _resenaCtrl,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Reseña',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.format_quote),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().length < 5)
                  ? 'Escribe al menos 5 caracteres'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _autorCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Autor',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribe el autor' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(_esEdicion ? 'Guardar cambios' : 'Guardar reseña'),
            ),
          ],
        ),
      ),
    );
  }
}