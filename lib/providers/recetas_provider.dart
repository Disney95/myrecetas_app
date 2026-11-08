import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../db/db_helper.dart';
import '../models/receta.dart';
import '../models/insumo.dart';
import '../utils/unidades.dart';

class RecetasProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  final _uuid = const Uuid();

  List<Receta> _recetas = [];
  bool cargando = true;

  List<Receta> get recetas => _recetas;

  // Último listado de insumos del almacén (para mantener los costos al día)
  List<Insumo> _insumosAlmacen = [];

  /// Recalcula los precios de los ingredientes con los precios actuales del
  /// almacén (suban o bajen) y guarda las recetas que hayan cambiado.
  Future<void> sincronizarConAlmacen(List<Insumo> insumos) async {
    _insumosAlmacen = List<Insumo>.from(insumos);
    await _aplicarAlmacen();
  }

  Future<void> _aplicarAlmacen() async {
    if (_insumosAlmacen.isEmpty || _recetas.isEmpty) return;
    bool huboCambios = false;
    for (final receta in _recetas) {
      bool recetaCambio = false;
      for (final ing in receta.ingredientes) {
        final nombre = ing.nombre.trim().toLowerCase();
        for (final insumo in _insumosAlmacen) {
          if (insumo.nombre.trim().toLowerCase() == nombre &&
              UnidadesUtil.sonCompatibles(insumo.unidad, ing.unidad)) {
            if (ing.actualizarDesdeInsumo(insumo)) recetaCambio = true;
            break;
          }
        }
      }
      if (recetaCambio) {
        huboCambios = true;
        await _db.guardarReceta(receta);
      }
    }
    if (huboCambios) notifyListeners();
  }

  RecetasProvider() {
    cargarRecetas();
  }

  Future<void> cargarRecetas() async {
    cargando = true;
    notifyListeners();
    _recetas = await _db.obtenerRecetas();
    cargando = false;
    notifyListeners();
    await _aplicarAlmacen();
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
