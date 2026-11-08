import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/receta.dart';
import '../providers/recetas_provider.dart';
import '../theme/app_theme.dart';
import 'crear_editar_receta_screen.dart';

class DetalleRecetaScreen extends StatelessWidget {
  final Receta receta;
  const DetalleRecetaScreen({super.key, required this.receta});

  Widget _imagen(Receta receta) {
    if (receta.imagenPath == null || receta.imagenPath!.isEmpty) {
      return Container(
        height: 220,
        color: AppColors.acentoCrema,
        child: const Icon(Icons.restaurant_menu, size: 48, color: AppColors.textoSecundario),
      );
    }
    final img = receta.imagenPath!.startsWith('http')
        ? Image.network(receta.imagenPath!, height: 220, width: double.infinity, fit: BoxFit.cover)
        : Image.file(File(receta.imagenPath!), height: 220, width: double.infinity, fit: BoxFit.cover);
    return img;
  }

  @override
  Widget build(BuildContext context) {
    // Usa siempre la versión actualizada de la receta (precios del almacén al día)
    final receta = context
        .watch<RecetasProvider>()
        .recetas
        .firstWhere((r) => r.id == this.receta.id, orElse: () => this.receta);
    return Scaffold(
      appBar: AppBar(
        title: Text(receta.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => CrearEditarRecetaScreen(recetaExistente: receta))),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Eliminar receta'),
                  content: Text('¿Eliminar "${receta.nombre}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
                  ],
                ),
              );
              if (confirmar == true && context.mounted) {
                await context.read<RecetasProvider>().eliminarReceta(receta.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _imagen(receta),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _infoChip(context, Icons.category_outlined, receta.categoria),
                  _infoChip(context, Icons.thermostat, 'Temp. ${receta.temperatura} °C'),
                  _infoChip(context, Icons.local_fire_department_outlined, 'Cocción ${receta.tiempoCoccion} min'),
                  _infoChip(context, Icons.restaurant_outlined, '${receta.porciones.toStringAsFixed(0)} porciones'),
                ]),
                const SizedBox(height: 24),

                Text('Ingredientes', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...receta.ingredientes.map((i) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('${i.nombre}'),
                        subtitle: Text('${i.cantidad} ${i.unidad}'),
                        trailing: Text('\$${i.costoCalculado.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )),
                const SizedBox(height: 24),

                Text('Pasos de preparación', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...receta.pasos.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.acentoMenta.withOpacity(0.15),
                            child: Text('${e.key + 1}',
                                style: const TextStyle(color: AppColors.acentoMenta, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(e.value, style: Theme.of(context).textTheme.bodyLarge)),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),

                Text('Resumen financiero', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _filaResumen(context, 'Costo materia prima', receta.costoMateriaPrima),
                        _filaResumen(context, 'Costos indirectos (${receta.costosIndirectosPorcentaje.toStringAsFixed(0)}%)', receta.costoIndirecto),
                        _filaResumen(context, 'Costo total de producción', receta.costoTotalProduccion),
                        _filaResumen(context, 'Costo por porción', receta.costoPorPorcion),
                        const Divider(height: 24),
                        _filaResumen(context, 'Precio de venta sugerido', receta.precioVentaSugerido, destacado: true),
                        _filaResumen(context, 'Ganancia neta por porción', receta.gananciaNetaPorPorcion),
                        _filaResumen(context, 'Ganancia neta del lote', receta.gananciaNetaTotalLote),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: context.colorTarjeta, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.colorDivisor)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: context.colorSecundario),
        const SizedBox(width: 6),
        Text(texto, style: TextStyle(fontSize: 12, color: context.colorSecundario)),
      ]),
    );
  }

  Widget _filaResumen(BuildContext context, String label, double valor, {bool destacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text('\$${valor.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: destacado ? AppColors.exito : context.colorPrincipal, fontSize: destacado ? 18 : 14)),
      ]),
    );
  }
}
