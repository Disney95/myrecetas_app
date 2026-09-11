import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../db/db_helper.dart';
import '../models/receta.dart';

class RecetasProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  final _uuid = const Uuid();

  List<Receta> _recetas = [];
  bool cargando = true;

  List<Receta> get recetas => _recetas;

  RecetasProvider() {
    cargarRecetas();
  }

  Future<void> cargarRecetas() async {
    cargando = true;
    notifyListeners();
    _recetas = await _db.obtenerRecetas();
    cargando = false;
    notifyListeners();
  }

  List<Receta> porCategoria(String categoria) =>
      _recetas.where((r) => r.categoria == categoria).toList();

  List<Receta> buscar(String query) {
    if (query.trim().isEmpty) return _recetas;
    final q = query.toLowerCase();
    return _recetas.where((r) => r.nombre.toLowerCase().contains(q)).toList();
  }

  String generarId() => _uuid.v4();

  Future<void> guardarReceta(Receta receta) async {
    await _db.guardarReceta(receta);
    await cargarRecetas();
  }

  Future<void> eliminarReceta(String id) async {
    await _db.eliminarReceta(id);
    await cargarRecetas();
  }

  // ---- Estadísticas globales para el panel de Finanzas ----
  double get inversionTotalEstimada =>
      _recetas.fold(0.0, (s, r) => s + r.costoTotalProduccion);

  double get gananciaTotalEstimada =>
      _recetas.fold(0.0, (s, r) => s + r.gananciaNetaTotalLote);
}
