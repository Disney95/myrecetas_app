/// Agrupa las unidades de medida por tipo y permite convertir cualquier
/// cantidad a la unidad base de su grupo (gramos para peso, mililitros
/// para volumen). Así se puede comparar/calcular precios aunque el
/// almacén use una unidad distinta a la de la receta.
enum GrupoUnidad { peso, volumen, conteo }

class UnidadesUtil {
  static const Map<String, double> _factoresPeso = {
    'g': 1,
    'kg': 1000,
    'lb': 453.592,
    'onz': 28.3495,
  };

  static const Map<String, double> _factoresVolumen = {
    'ml': 1,
    'l': 1000,
    'cdita': 4.92892,
    'cda': 14.7868,
    'taza': 236.588,
  };

  static GrupoUnidad grupoDe(String unidad) {
    if (_factoresPeso.containsKey(unidad)) return GrupoUnidad.peso;
    if (_factoresVolumen.containsKey(unidad)) return GrupoUnidad.volumen;
    return GrupoUnidad.conteo;
  }

  /// Convierte [cantidad] de [unidad] a la unidad base de su grupo
  /// (gramos, mililitros, o la misma cantidad si es "unidad").
  static double aBase(String unidad, double cantidad) {
    final grupo = grupoDe(unidad);
    switch (grupo) {
      case GrupoUnidad.peso:
        return cantidad * (_factoresPeso[unidad] ?? 1);
      case GrupoUnidad.volumen:
        return cantidad * (_factoresVolumen[unidad] ?? 1);
      case GrupoUnidad.conteo:
        return cantidad;
    }
  }

  static bool sonCompatibles(String unidadA, String unidadB) {
    return grupoDe(unidadA) == grupoDe(unidadB);
  }

  static const List<String> todasLasUnidades = [
    'g', 'kg', 'lb', 'onz', 'ml', 'l', 'cdita', 'cda', 'taza', 'unidad'
  ];
}
