import '../utils/unidades.dart';

class Insumo {
  String id;
  String nombre;
  double cantidadComprada;
  String unidad;
  double costoTotal; // siempre en CUP (usado para todos los cálculos)
  String moneda; // moneda en la que el usuario ingresó el costo ('cup','usd','eur')
  double costoOriginal; // valor tal cual lo escribió el usuario, en `moneda`

  Insumo({
    required this.id,
    required this.nombre,
    required this.cantidadComprada,
    required this.unidad,
    required this.costoTotal,
    this.moneda = 'cup',
    double? costoOriginal,
  }) : costoOriginal = costoOriginal ?? costoTotal;

  /// Costo por unidad base del grupo (por gramo, por mililitro, o por
  /// unidad si es conteo). Ej: 50kg a $20000 -> $0.4 por gramo.
  double get costoPorUnidadBase {
    final base = UnidadesUtil.aBase(unidad, cantidadComprada);
    if (base <= 0) return 0;
    return costoTotal / base;
  }

  double get costoPorUnidadPropia {
    if (cantidadComprada <= 0) return 0;
    return costoTotal / cantidadComprada;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'cantidadComprada': cantidadComprada,
        'unidad': unidad,
        'costoTotal': costoTotal,
        'moneda': moneda,
        'costoOriginal': costoOriginal,
      };

  factory Insumo.fromMap(Map<String, dynamic> map) => Insumo(
        id: map['id'],
        nombre: map['nombre'],
        cantidadComprada: (map['cantidadComprada'] as num).toDouble(),
        unidad: map['unidad'],
        costoTotal: (map['costoTotal'] as num).toDouble(),
        moneda: (map['moneda'] as String?) ?? 'cup',
        costoOriginal: (map['costoOriginal'] as num?)?.toDouble(),
      );
}
