import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../db/db_helper.dart';
import '../models/categoria_custom.dart';
import '../models/receta.dart';

class CategoriasProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  final _uuid = const Uuid();

  // Semilla sincrónica: evita que la app arranque sin categorías mientras
  // se carga la base de datos. Se reemplaza en cuanto `cargar()` responde.
  // "Todas" es una categoría especial y siempre va primero: agrupa todas
  // las recetas, se puede editar (solo su imagen) pero no se puede
  // renombrar ni eliminar.
  List<CategoriaCustom> _categorias = [
    CategoriaCustom(id: 'todas', nombre: 'Todas', orden: -1),
    for (var i = 0; i < categoriasPorDefecto.length; i++)
      CategoriaCustom(id: 'default_$i', nombre: categoriasPorDefecto[i], orden: i),
  ];

  CategoriasProvider() {
    cargar();
  }

  Future<void> cargar() async {
    final cargadas = await _db.obtenerCategorias();
    if (cargadas.isNotEmpty) _categorias = cargadas;
    notifyListeners();
  }

  /// Todas las categorías disponibles, ya editables (ya no hay distinción
  /// entre "por defecto" y "personalizadas": todas viven en la misma tabla).
  /// Incluye la categoría especial "Todas".
  List<CategoriaCustom> get categorias => List.unmodifiable(_categorias);

  /// Nombres de categorías asignables a una receta: excluye "Todas", que no
  /// es una categoría real sino un filtro que agrupa a todas las recetas.
  List<String> get nombres =>
      _categorias.where((c) => c.id != 'todas').map((c) => c.nombre).toList();

  String? imagenDe(String nombreCategoria) {
    for (final c in _categorias) {
      if (c.nombre == nombreCategoria) return c.imagenPath;
    }
    return null;
  }

  Future<void> agregarCategoria(String nombre, String? imagenPath) async {
    if (nombre.trim().isEmpty) return;
    final ordenSiguiente = _categorias.isEmpty
        ? 0
        : (_categorias.map((c) => c.orden).reduce((a, b) => a > b ? a : b) + 1);
    await _db.guardarCategoria(CategoriaCustom(
      id: _uuid.v4(),
      nombre: nombre.trim(),
      imagenPath: imagenPath,
      orden: ordenSiguiente,
    ));
    await cargar();
  }

  Future<void> editarCategoria(CategoriaCustom categoria,
      {required String nombre, String? imagenPath}) async {
    // "Todas" tiene el nombre fijo: solo se le puede cambiar la imagen.
    final esTodas = categoria.id == 'todas';
    final nombreFinal = esTodas ? 'Todas' : nombre.trim();
    if (!esTodas && nombreFinal.isEmpty) return;
    await _db.guardarCategoria(CategoriaCustom(
      id: categoria.id,
      nombre: nombreFinal,
      imagenPath: imagenPath,
      orden: categoria.orden,
    ));
    await cargar();
  }

  Future<void> eliminarCategoria(CategoriaCustom categoria) async {
    if (categoria.id == 'todas') return; // no se puede eliminar
    await _db.eliminarCategoria(categoria.id);
    await cargar();
  }
}
