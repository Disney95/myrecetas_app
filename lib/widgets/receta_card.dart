import 'dart:io';
import 'package:flutter/material.dart';
import '../models/receta.dart';
import '../theme/app_theme.dart';

class RecetaCard extends StatelessWidget {
  final Receta receta;
  final VoidCallback onTap;

  const RecetaCard({super.key, required this.receta, required this.onTap});

  Widget _imagen() {
    if (receta.imagenPath == null || receta.imagenPath!.isEmpty) {
      return Container(
        color: AppColors.acentoCrema,
        child: const Icon(Icons.restaurant_menu, color: AppColors.textoSecundario, size: 32),
      );
    }
    if (receta.imagenPath!.startsWith('http')) {
      return Image.network(receta.imagenPath!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: AppColors.acentoCrema));
    }
    return Image.file(File(receta.imagenPath!), fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: AppColors.acentoCrema));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(width: 90, height: 90, child: _imagen()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(receta.nombre,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(receta.categoria,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _chip('Costo/porción \$${receta.costoPorPorcion.toStringAsFixed(2)}',
                            AppColors.textoPrincipal),
                        const SizedBox(width: 6),
                        _chip('Margen ${receta.margenGanancia.toStringAsFixed(0)}%',
                            AppColors.exito),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(texto, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
