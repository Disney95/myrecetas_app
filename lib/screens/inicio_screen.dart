import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recetas_provider.dart';
import '../providers/categorias_provider.dart';
import '../models/receta.dart';
import '../theme/app_theme.dart';
import 'detalle_receta_screen.dart';
import 'ajustes_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  String? _filtro; // null = Todas

  @override
  Widget build(BuildContext context) {
    final recetasProvider = context.watch<RecetasProvider>();
    final categoriasProvider = context.watch<CategoriasProvider>();
    final recetas = _filtro == null
        ? recetasProvider.recetas
        : recetasProvider.porCategoria(_filtro!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetario y Costos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes',
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AjustesScreen())),
          ),
        ],
      ),
      body: recetasProvider.cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: recetasProvider.cargarRecetas,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Categorías', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _tarjetaCategoria(context, 'Todas',
                            categoriasProvider.imagenDe('Todas'), _filtro == null),
                        ...categoriasProvider.nombres.map((c) => _tarjetaCategoria(
                            context, c, categoriasProvider.imagenDe(c), _filtro == c)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Recetas recientes', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(height: 10),
                  if (recetas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                      child: Center(
                        child: Text('Aún no hay recetas.\nCreá tu primera ficha técnica.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    )
                  else
                    SizedBox(
                      height: 190,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: recetas
                            .map((r) => _tarjetaReceta(context, r))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _tarjetaCategoria(BuildContext context, String nombre, String? imagenPath, bool seleccionada) {
    return GestureDetector(
      onTap: () => setState(() => _filtro = nombre == 'Todas' ? null : nombre),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.acentoCrema,
          image: imagenPath != null
              ? DecorationImage(image: FileImage(File(imagenPath)), fit: BoxFit.cover)
              : null,
        ),
        child: Stack(
          children: [
            if (imagenPath == null)
              const Center(child: Icon(Icons.category_outlined, size: 30, color: AppColors.textoSecundario)),
            if (seleccionada)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: AppColors.acentoMenta, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0), Colors.black.withOpacity(0.55)],
                  ),
                ),
                child: Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaReceta(BuildContext context, Receta receta) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetalleRecetaScreen(receta: receta))),
      child: Container(
        width: 165,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divisor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,
              child: _imagenReceta(receta),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(receta.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _datoChico('${receta.tiempoCoccion}min')),
                      _divisorVertical(),
                      Expanded(child: _datoChico('${receta.precioVentaSugerido.toStringAsFixed(0)}cup')),
                      _divisorVertical(),
                      Expanded(child: _datoChico('${receta.porciones.toStringAsFixed(0)} und')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datoChico(String texto) {
    return Text(
      texto,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10.5, color: AppColors.textoSecundario, fontWeight: FontWeight.w600),
    );
  }

  Widget _divisorVertical() {
    return Container(width: 1, height: 12, color: AppColors.divisor, margin: const EdgeInsets.symmetric(horizontal: 4));
  }

  Widget _imagenReceta(Receta receta) {
    if (receta.imagenPath == null || receta.imagenPath!.isEmpty) {
      return Container(
        color: AppColors.acentoCrema,
        child: const Icon(Icons.restaurant_menu, color: AppColors.textoSecundario, size: 28),
      );
    }
    if (receta.imagenPath!.startsWith('http')) {
      return Image.network(receta.imagenPath!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: AppColors.acentoCrema));
    }
    return Image.file(File(receta.imagenPath!), fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: AppColors.acentoCrema));
  }
}
