import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../db/db_helper.dart';
import '../models/insumo.dart';
import '../utils/unidades.dart';

class AlmacenProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  final _uuid = const Uuid();

  List<Insumo> _insumos = [];
  List<Insumo> get insumos => _insumos;

  AlmacenProvider() {
    cargarInsumos();
  }

  Future<void> cargarInsumos() async {
    _insumos = await _db.obtenerInsumos();
    notifyListeners();
  }

  Future<void> guardarInsumo({
    String? id,
    required String nombre,
    required double cantidadComprada,
    required String unidad,
    required double costoTotal,
  }) async {
    final insumo = Insumo(
      id: id ?? _uuid.v4(),
      nombre: nombre,
      cantidadComprada: cantidadComprada,
      unidad: unidad,
      costoTotal: costoTotal,
    );
    await _db.guardarInsumo(insumo);
    await cargarInsumos();
  }

  Future<void> eliminarInsumo(String id) async {
    await _db.eliminarInsumo(id);
    await cargarInsumos();
  }

  /// Busca un insumo por nombre (sin distinguir mayúsculas/tildes exactas)
  /// que además tenga una unidad compatible con [unidadObjetivo].
  Insumo? buscarPorNombre(String nombre, String unidadObjetivo) {
    final q = nombre.trim().toLowerCase();
    if (q.isEmpty) return null;
    for (final insumo in _insumos) {
      if (insumo.nombre.trim().toLowerCase() == q &&
          UnidadesUtil.sonCompatibles(insumo.unidad, unidadObjetivo)) {
        return insumo;
      }
    }
    return null;
  }

  /// Precio calculado para [cantidad] [unidad] del ingrediente, usando el
  /// precio de referencia cargado en el almacén para ese producto.
  double? precioParaCantidad(String nombre, double cantidad, String unidad) {
    final insumo = buscarPorNombre(nombre, unidad);
    if (insumo == null) return null;
    return insumo.costoPorUnidadBase * UnidadesUtil.aBase(unidad, cantidad);
  }
}
