import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/recetas_provider.dart';
import '../theme/app_theme.dart';

class FinanzasScreen extends StatelessWidget {
  const FinanzasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecetasProvider>();
    final recetas = provider.recetas;
    final inversion = provider.inversionTotalEstimada;
    final ganancia = provider.gananciaTotalEstimada;
    final total = inversion + ganancia;

    return Scaffold(
      appBar: AppBar(title: const Text('Finanzas y Costos')),
      body: recetas.isEmpty
          ? Center(child: Text('Agregá recetas para ver tu panel financiero', style: Theme.of(context).textTheme.bodyMedium))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(children: [
                  Expanded(child: _tarjetaResumen('Inversión estimada', inversion, AppColors.textoPrincipal)),
                  const SizedBox(width: 12),
                  Expanded(child: _tarjetaResumen('Ganancia estimada', ganancia, AppColors.exito)),
                ]),
                const SizedBox(height: 20),
                Text('Inversión vs. Ganancia', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 14),
                SizedBox(
                  height: 180,
                  child: total <= 0
                      ? const SizedBox()
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 45,
                            sections: [
                              PieChartSectionData(
                                value: inversion,
                                color: AppColors.acentoTerracota,
                                title: '${((inversion / total) * 100).toStringAsFixed(0)}%',
                                radius: 55,
                                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                value: ganancia,
                                color: AppColors.acentoMenta,
                                title: '${((ganancia / total) * 100).toStringAsFixed(0)}%',
                                radius: 55,
                                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _leyenda('Inversión', AppColors.acentoTerracota),
                  const SizedBox(width: 20),
                  _leyenda('Ganancia', AppColors.acentoMenta),
                ]),
                const SizedBox(height: 24),
                Text('Rentabilidad por receta', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...recetas.map((r) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(r.nombre),
                        subtitle: Text('Costo/porción \$${r.costoPorPorcion.toStringAsFixed(2)} · Venta \$${r.precioVentaSugerido.toStringAsFixed(2)}'),
                        trailing: Text('+\$${r.gananciaNetaPorPorcion.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.exito, fontWeight: FontWeight.bold)),
                      ),
                    )),
              ],
            ),
    );
  }

  Widget _tarjetaResumen(String label, double valor, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textoSecundario, fontSize: 13)),
            const SizedBox(height: 6),
            Text('\$${valor.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _leyenda(String texto, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(texto, style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario)),
    ]);
  }
}
