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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(width: 104, height: 104, child: _imagen()),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(receta.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _dato('${receta.tiempoCoccion}min'),
                          _divisorVertical(),
                          _dato('${receta.tiempoPreparacion}min'),
                          _divisorVertical(),
                          _dato(receta.porciones.toStringAsFixed(0)),
                          _divisorVertical(),
                          _dato('${receta.precioVentaSugerido.toStringAsFixed(0)}cup'),
                        ],
                      ),
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
      ),
    );
  }

  Widget _dato(String texto) {
    return Text(
      texto,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 13, color: AppColors.textoSecundario, fontWeight: FontWeight.w600),
    );
  }

  Widget _divisorVertical() {
    return Container(
      width: 1,
      height: 12,
      color: AppColors.divisor,
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
