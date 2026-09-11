import 'dart:convert';
import 'ingrediente.dart';

/// Categorías por defecto que siempre existen. El usuario puede agregar
/// más desde Ajustes → Categoría.
const List<String> categoriasPorDefecto = [
  'Postres/Dulces',
  'Salados/Comidas',
  'Bebidas',
];

class Receta {
  String id;
  String nombre;
  String categoria;
  String? imagenPath; // ruta local o URL
  int tiempoPreparacion; // minutos
  int tiempoCoccion; // minutos
  double porciones;
  List<Ingrediente> ingredientes;
  List<String> pasos;
  double costosIndirectosPorcentaje; // %
  double margenGanancia; // %
  DateTime fechaCreacion;

  Receta({
    required this.id,
    required this.nombre,
    required this.categoria,
    this.imagenPath,
    this.tiempoPreparacion = 0,
    this.tiempoCoccion = 0,
    this.porciones = 1,
    List<Ingrediente>? ingredientes,
    List<String>? pasos,
    this.costosIndirectosPorcentaje = 15,
    this.margenGanancia = 50,
    DateTime? fechaCreacion,
  })  : ingredientes = ingredientes ?? [],
        pasos = pasos ?? [],
        fechaCreacion = fechaCreacion ?? DateTime.now();

  double get costoMateriaPrima =>
      ingredientes.fold(0.0, (sum, i) => sum + i.costoCalculado);

  double get costoIndirecto =>
      costoMateriaPrima * (costosIndirectosPorcentaje / 100);

  double get costoTotalProduccion => costoMateriaPrima + costoIndirecto;

  double get costoPorPorcion =>
      porciones > 0 ? costoTotalProduccion / porciones : 0;

  double get precioVentaSugerido =>
      costoPorPorcion * (1 + margenGanancia / 100);

  double get gananciaNetaPorPorcion => precioVentaSugerido - costoPorPorcion;

  double get gananciaNetaTotalLote => gananciaNetaPorPorcion * porciones;

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'categoria': categoria,
        'imagenPath': imagenPath,
        'tiempoPreparacion': tiempoPreparacion,
        'tiempoCoccion': tiempoCoccion,
        'porciones': porciones,
        'ingredientes': jsonEncode(ingredientes.map((e) => e.toMap()).toList()),
        'pasos': jsonEncode(pasos),
        'costosIndirectosPorcentaje': costosIndirectosPorcentaje,
        'margenGanancia': margenGanancia,
        'fechaCreacion': fechaCreacion.toIso8601String(),
      };

  factory Receta.fromMap(Map<String, dynamic> map) => Receta(
        id: map['id'],
        nombre: map['nombre'],
        categoria: map['categoria'] ?? categoriasPorDefecto.first,
        imagenPath: map['imagenPath'],
        tiempoPreparacion: map['tiempoPreparacion'] ?? 0,
        tiempoCoccion: map['tiempoCoccion'] ?? 0,
        porciones: (map['porciones'] as num).toDouble(),
        ingredientes: (jsonDecode(map['ingredientes']) as List)
            .map((e) => Ingrediente.fromMap(e))
            .toList(),
        pasos: (jsonDecode(map['pasos']) as List).map((e) => e.toString()).toList(),
        costosIndirectosPorcentaje:
            (map['costosIndirectosPorcentaje'] as num).toDouble(),
        margenGanancia: (map['margenGanancia'] as num).toDouble(),
        fechaCreacion: DateTime.parse(map['fechaCreacion']),
      );
}
