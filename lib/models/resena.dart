class Resena {
  final int? id;
  final int recetaId;
  final String resena;
  final String autor;

  const Resena({
    this.id,
    required this.recetaId,
    required this.resena,
    required this.autor,
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'recetaId': recetaId,
      'resena': resena,
      'autor': autor,
    };
  }

  factory Resena.fromMap(Map<String, Object?> mapa) {
    return Resena(
      id: mapa['id'] as int?,
      recetaId: mapa['recetaId'] as int,
      resena: mapa['resena'] as String,
      autor: mapa['autor'] as String,
    );
  }
}