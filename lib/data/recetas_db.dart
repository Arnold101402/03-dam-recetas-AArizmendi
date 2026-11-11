import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/resena.dart';

class RecetasDb {
  RecetasDb._();
  static final RecetasDb instancia = RecetasDb._();
  static const _nombreArchivo = 'misrecetas.db';
  static const _tabla = 'resenas';
  Database? _db;

  // devuelve la bd abierta (la abre solo la primera vez). PdD: Singleton
  Future<Database> get _database async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), _nombreArchivo);
    return openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE $_tabla (
id INTEGER PRIMARY KEY AUTOINCREMENT,
recetaId INTEGER NOT NULL,
resena TEXT NOT NULL,
autor TEXT NOT NULL
)
''');
      },
    );
  }

  // guarda y devuelve el id
  Future<int> insert(Resena resena) async {
    final db = await _database;
    return db.insert(_tabla, resena.toMap());
  }

  // lee todas las reseñas de una receta específica de manera descendente
  Future<List<Resena>> obtenerPorReceta(int recetaId) async {
    final db = await _database;
    final filas = await db.query(
      _tabla,
      where: 'recetaId = ?',
      whereArgs: [recetaId],
      orderBy: 'id DESC',
    );
    return filas.map(Resena.fromMap).toList();
  }

  // modifica usando el id
  Future<int> actualizar(Resena resena) async {
    final db = await _database;
    return db.update(
      _tabla,
      resena.toMap(),
      where: 'id = ?',
      whereArgs: [resena.id],
    );
  }

  // elimina la reseña con el id
  Future<int> eliminar(int id) async {
    final db = await _database;
    return db.delete(_tabla, where: 'id = ?', whereArgs: [id]);
  }
}