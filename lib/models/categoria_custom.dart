class CategoriaCustom {
  String id;
  String nombre;
  String? imagenPath;

  CategoriaCustom({
    required this.id,
    required this.nombre,
    this.imagenPath,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'imagenPath': imagenPath,
      };

  factory CategoriaCustom.fromMap(Map<String, dynamic> map) => CategoriaCustom(
        id: map['id'],
        nombre: map['nombre'],
        imagenPath: map['imagenPath'],
      );
}
