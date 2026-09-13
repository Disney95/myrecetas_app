import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/licencia_provider.dart';
import '../theme/app_theme.dart';

class ActivarLicenciaScreen extends StatefulWidget {
  const ActivarLicenciaScreen({super.key});

  @override
  State<ActivarLicenciaScreen> createState() => _ActivarLicenciaScreenState();
}

class _ActivarLicenciaScreenState extends State<ActivarLicenciaScreen> {
  final _codigoCtrl = TextEditingController();
  bool _verificando = false;

  @override
  void dispose() {
    _codigoCtrl.dispose();
    super.dispose();
  }

  Future<void> _activar() async {
    final licencia = context.read<LicenciaProvider>();
    setState(() => _verificando = true);
    final ok = await licencia.activar(_codigoCtrl.text);
    if (!mounted) return;
    setState(() => _verificando = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡App activada correctamente!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ese código no es válido. Revisalo e intentá de nuevo.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final licencia = context.watch<LicenciaProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Activar app')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            licencia.bloqueada ? Icons.lock_outline : Icons.timer_outlined,
            size: 56,
            color: AppColors.acentoMenta,
          ),
          const SizedBox(height: 16),
          Text(
            licencia.bloqueada
                ? 'Tu prueba gratuita terminó'
                : 'Te quedan ${licencia.diasRestantes} día${licencia.diasRestantes == 1 ? '' : 's'} de prueba gratis',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'La activación queda ligada a este celular y desbloquea todas las funciones de forma permanente.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divisor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1. Enviá este código a quien te vendió la app',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        licencia.identificador.isEmpty ? '...' : licencia.identificador,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copiar',
                      icon: const Icon(Icons.copy, size: 20, color: AppColors.acentoMenta),
                      onPressed: licencia.identificador.isEmpty
                          ? null
                          : () {
                              Clipboard.setData(ClipboardData(text: licencia.identificador));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Código de dispositivo copiado')));
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('2. Pegá aquí el código de activación que te devuelvan',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _codigoCtrl,
            maxLines: 4,
            minLines: 2,
            decoration: const InputDecoration(
              hintText: 'Pegá aquí el código',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verificando ? null : _activar,
              child: _verificando
                  ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Activar'),
            ),
          ),
        ],
      ),
    );
  }
}
