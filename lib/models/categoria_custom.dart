class CategoriaCustom {
  String id;
  String nombre;
  String? imagenPath;
  int orden;

  CategoriaCustom({
    required this.id,
    required this.nombre,
    this.imagenPath,
    this.orden = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'imagenPath': imagenPath,
        'orden': orden,
      };

  factory CategoriaCustom.fromMap(Map<String, dynamic> map) => CategoriaCustom(
        id: map['id'],
        nombre: map['nombre'],
        imagenPath: map['imagenPath'],
        orden: (map['orden'] as num?)?.toInt() ?? 0,
      );
}
