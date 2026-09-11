import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tema_provider.dart';
import '../theme/app_theme.dart';

class AjustesTemaScreen extends StatelessWidget {
  const AjustesTemaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TemaProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tema')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _opcion(context, 'Claro', Icons.light_mode_outlined, ThemeMode.light, provider),
          _opcion(context, 'Oscuro', Icons.dark_mode_outlined, ThemeMode.dark, provider),
          _opcion(context, 'Sistema', Icons.smartphone_outlined, ThemeMode.system, provider),
        ],
      ),
    );
  }

  Widget _opcion(BuildContext context, String titulo, IconData icon, ThemeMode modo, TemaProvider provider) {
    final seleccionado = provider.modo == modo;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: seleccionado ? AppColors.acentoMenta : AppColors.textoSecundario),
        title: Text(titulo),
        trailing: seleccionado ? const Icon(Icons.check_circle, color: AppColors.acentoMenta) : null,
        onTap: () => provider.setModo(modo),
      ),
    );
  }
}
