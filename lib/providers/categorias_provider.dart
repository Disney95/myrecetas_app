import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../db/db_helper.dart';
import '../models/categoria_custom.dart';
import '../models/receta.dart';

class CategoriasProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  final _uuid = const Uuid();

  List<CategoriaCustom> _personalizadas = [];

  CategoriasProvider() {
    cargar();
  }

  Future<void> cargar() async {
    _personalizadas = await _db.obtenerCategorias();
    notifyListeners();
  }

  /// Todas las categorías disponibles: las 3 por defecto + las que el
  /// usuario haya creado.
  List<String> get nombres => [
        ...categoriasPorDefecto,
        ..._personalizadas.map((c) => c.nombre),
      ];

  String? imagenDe(String nombreCategoria) {
    for (final c in _personalizadas) {
      if (c.nombre == nombreCategoria) return c.imagenPath;
    }
    return null;
  }

  Future<void> agregarCategoria(String nombre, String? imagenPath) async {
    if (nombre.trim().isEmpty) return;
    await _db.guardarCategoria(CategoriaCustom(
      id: _uuid.v4(),
      nombre: nombre.trim(),
      imagenPath: imagenPath,
    ));
    await cargar();
  }

  Future<void> eliminarCategoria(CategoriaCustom categoria) async {
    await _db.eliminarCategoria(categoria.id);
    await cargar();
  }

  List<CategoriaCustom> get personalizadas => _personalizadas;
}
