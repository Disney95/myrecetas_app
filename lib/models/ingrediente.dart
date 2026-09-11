class Ingrediente {
  String id;
  String nombre;
  double cantidad; // cantidad usada en la receta
  String unidad; // g, kg, ml, l, cdita, unidad, etc.
  double precioCompra; // precio pagado por la cantidadCompra
  double cantidadCompra; // cantidad de referencia comprada (ej. 1000 para 1000g)

  Ingrediente({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.unidad,
    required this.precioCompra,
    required this.cantidadCompra,
  });

  /// Costo proporcional calculado automáticamente según la cantidad usada.
  double get costoCalculado {
    if (cantidadCompra <= 0) return 0;
    return (precioCompra / cantidadCompra) * cantidad;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'cantidad': cantidad,
        'unidad': unidad,
        'precioCompra': precioCompra,
        'cantidadCompra': cantidadCompra,
      };

  factory Ingrediente.fromMap(Map<String, dynamic> map) => Ingrediente(
        id: map['id'],
        nombre: map['nombre'],
        cantidad: (map['cantidad'] as num).toDouble(),
        unidad: map['unidad'],
        precioCompra: (map['precioCompra'] as num).toDouble(),
        cantidadCompra: (map['cantidadCompra'] as num).toDouble(),
      );
}
