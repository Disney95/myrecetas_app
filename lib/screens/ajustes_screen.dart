import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ajustes_categoria_screen.dart';
import 'ajustes_tema_screen.dart';
import 'ajustes_moneda_screen.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _opcion(
            context,
            icon: Icons.category_outlined,
            titulo: 'Categoría',
            subtitulo: 'Creá tus propias categorías de recetas',
            destino: const AjustesCategoriaScreen(),
          ),
          _opcion(
            context,
            icon: Icons.brightness_6_outlined,
            titulo: 'Tema',
            subtitulo: 'Claro, oscuro o según el sistema',
            destino: const AjustesTemaScreen(),
          ),
          _opcion(
            context,
            icon: Icons.attach_money_outlined,
            titulo: 'Moneda',
            subtitulo: 'EUR, USD y conversión a CUP',
            destino: const AjustesMonedaScreen(),
          ),
        ],
      ),
    );
  }

  Widget _opcion(BuildContext context,
      {required IconData icon,
      required String titulo,
      required String subtitulo,
      required Widget destino}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.acentoMenta),
        title: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitulo, style: Theme.of(context).textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textoSecundario),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destino)),
      ),
    );
  }
}
