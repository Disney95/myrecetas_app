import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/moneda_provider.dart';
import '../theme/app_theme.dart';

class AjustesMonedaScreen extends StatefulWidget {
  const AjustesMonedaScreen({super.key});

  @override
  State<AjustesMonedaScreen> createState() => _AjustesMonedaScreenState();
}

class _AjustesMonedaScreenState extends State<AjustesMonedaScreen> {
  late TextEditingController _usdCtrl;
  late TextEditingController _eurCtrl;

  @override
  void initState() {
    super.initState();
    final provider = context.read<MonedaProvider>();
    _usdCtrl = TextEditingController(
        text: provider.tasaUsdCup > 0 ? provider.tasaUsdCup.toString() : '');
    _eurCtrl = TextEditingController(
        text: provider.tasaEurCup > 0 ? provider.tasaEurCup.toString() : '');
  }

  @override
  void dispose() {
    _usdCtrl.dispose();
    _eurCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonedaProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Moneda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Moneda preferida', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...Moneda.values.map((m) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<Moneda>(
                  value: m,
                  groupValue: provider.monedaPreferida,
                  activeColor: AppColors.acentoMenta,
                  title: Text(m.simbolo),
                  onChanged: (v) => provider.setMonedaPreferida(v ?? provider.monedaPreferida),
                ),
              )),
          const SizedBox(height: 20),
          Text('Tasas de cambio a CUP', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Todos los costos se guardan internamente en CUP. Al cargar un precio en USD o EUR, se convierte automáticamente con estas tasas.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          TextField(
            controller: _usdCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '1 USD equivale a (CUP)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _eurCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '1 EUR equivale a (CUP)'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                provider.setTasas(
                  usdCup: double.tryParse(_usdCtrl.text),
                  eurCup: double.tryParse(_eurCtrl.text),
                );
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Tasas guardadas')));
              },
              child: const Text('Guardar tasas'),
            ),
          ),
        ],
      ),
    );
  }
}
