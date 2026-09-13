import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/licencia_provider.dart';
import 'ajustes_categoria_screen.dart';
import 'ajustes_tema_screen.dart';
import 'ajustes_moneda_screen.dart';
import 'activar_licencia_screen.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _info = info);
    });
  }

  @override
  Widget build(BuildContext context) {
    final licencia = context.watch<LicenciaProvider>();
    final bloqueado = !licencia.activada;
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
            bloqueado: bloqueado,
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  _info?.appName ?? 'MyRecestas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  _info == null
                      ? 'Versión...'
                      : 'Versión ${_info!.version} (build ${_info!.buildNumber})',
                  style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _opcion(BuildContext context,
      {required IconData icon,
      required String titulo,
      required String subtitulo,
      required Widget destino,
      bool bloqueado = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.acentoMenta),
        title: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitulo, style: Theme.of(context).textTheme.bodyMedium),
        trailing: bloqueado
            ? const Icon(Icons.lock_outline, color: AppColors.textoSecundario)
            : const Icon(Icons.chevron_right, color: AppColors.textoSecundario),
        onTap: () {
          if (bloqueado) {
            _mostrarBloqueado(context);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => destino));
          }
        },
      ),
    );
  }

  void _mostrarBloqueado(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Función bloqueada'),
        content: const Text(
            'Esta función se desbloquea al activar la app. Podés hacerlo con el código de activación.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivarLicenciaScreen()));
            },
            child: const Text('Activar'),
          ),
        ],
      ),
    );
  }
}
