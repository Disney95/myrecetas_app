import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/almacen_provider.dart';
import '../providers/moneda_provider.dart';
import '../models/insumo.dart';
import '../theme/app_theme.dart';
import '../utils/unidades.dart';

class AlmacenScreen extends StatelessWidget {
  const AlmacenScreen({super.key});

  void _agregarOEditar(BuildContext context, {Insumo? existente}) {
    final nombreCtrl = TextEditingController(text: existente?.nombre ?? '');
    final cantCtrl = TextEditingController(
        text: existente != null ? existente.cantidadComprada.toStringAsFixed(0) : '');
    // El campo muestra el valor ORIGINAL que escribió el usuario (en su
    // moneda), no el total ya convertido a CUP.
    final costoCtrl = TextEditingController(
        text: existente != null ? existente.costoOriginal.toStringAsFixed(0) : '');
    String unidad = existente?.unidad ?? 'kg';
    Moneda moneda = Moneda.values.firstWhere(
        (m) => m.name == (existente?.moneda ?? 'cup'),
        orElse: () => Moneda.cup);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final monedaProvider = context.read<MonedaProvider>();
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: StatefulBuilder(builder: (ctx, setModalState) {
            final cant = double.tryParse(cantCtrl.text) ?? 0;
            final costoIngresado = double.tryParse(costoCtrl.text) ?? 0;
            final costoTotalCup = monedaProvider.convertirACup(costoIngresado, moneda);
            final costoPorUnidad = cant > 0 ? costoTotalCup / cant : 0;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(existente == null ? 'Nuevo producto comprado' : 'Editar producto',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del producto'),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: cantCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Cantidad comprada'),
                        onChanged: (_) => setModalState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: unidad,
                        isDense: true,
                        decoration: const InputDecoration(
                          labelText: 'Unidad',
                          contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                        ),
                        items: UnidadesUtil.todasLasUnidades
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => setModalState(() => unidad = v ?? unidad),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: TextField(
                        controller: costoCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Costo total pagado'),
                        onChanged: (_) => setModalState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      child: DropdownButtonFormField<Moneda>(
                        value: moneda,
                        isDense: true,
                        decoration: const InputDecoration(
                          labelText: 'Moneda',
                          contentPadding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                        ),
                        items: Moneda.values
                            .map((m) => DropdownMenuItem(value: m, child: Text(m.simbolo)))
                            .toList(),
                        onChanged: (v) => setModalState(() => moneda = v ?? moneda),
                      ),
                    ),
                  ]),
                  if (moneda != Moneda.cup && costoIngresado > 0) ...[
                    const SizedBox(height: 6),
                    Text('≈ \$${costoTotalCup.toStringAsFixed(0)} CUP en total (según la tasa configurada en Ajustes → Moneda)',
                        style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario)),
                  ],
                  if (cant > 0 && costoTotalCup > 0) ...[
                    const SizedBox(height: 10),
                    Text('≈ \$${costoPorUnidad.toStringAsFixed(2)} por $unidad',
                        style: const TextStyle(color: AppColors.acentoMenta, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final nombre = nombreCtrl.text.trim();
                        final cantidad = double.tryParse(cantCtrl.text) ?? 0;
                        final costoOriginal = double.tryParse(costoCtrl.text) ?? 0;
                        if (nombre.isEmpty || cantidad <= 0 || costoOriginal <= 0) return;
                        final costoTotal = monedaProvider.convertirACup(costoOriginal, moneda);
                        await context.read<AlmacenProvider>().guardarInsumo(
                              id: existente?.id,
                              nombre: nombre,
                              cantidadComprada: cantidad,
                              unidad: unidad,
                              costoTotal: costoTotal,
                              moneda: moneda.name,
                              costoOriginal: costoOriginal,
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: Text(existente == null ? 'Agregar al almacén' : 'Guardar cambios'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlmacenProvider>();
    final insumos = provider.insumos;

    return Scaffold(
      appBar: AppBar(title: const Text('Almacén')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.acentoMenta,
        onPressed: () => _agregarOEditar(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: insumos.isEmpty
          ? Center(
              child: Text(
                'Todavía no cargaste productos.\nAgregá lo que compraste para el almacén.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: insumos.length,
              itemBuilder: (context, i) {
                final insumo = insumos[i];
                final monedaExt = Moneda.values.firstWhere(
                    (m) => m.name == insumo.moneda,
                    orElse: () => Moneda.cup);
                final subtitulo = monedaExt == Moneda.cup
                    ? '${insumo.cantidadComprada.toStringAsFixed(insumo.cantidadComprada % 1 == 0 ? 0 : 2)} ${insumo.unidad} · \$${insumo.costoTotal.toStringAsFixed(2)} total'
                    : '${insumo.cantidadComprada.toStringAsFixed(insumo.cantidadComprada % 1 == 0 ? 0 : 2)} ${insumo.unidad} · ${insumo.costoOriginal.toStringAsFixed(0)} ${monedaExt.simbolo} (\$${insumo.costoTotal.toStringAsFixed(2)} CUP)';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => _agregarOEditar(context, existente: insumo),
                    title: Text(insumo.nombre),
                    subtitle: Text(subtitulo),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${insumo.costoPorUnidadPropia.toStringAsFixed(2)}/${insumo.unidad}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.exito)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: AppColors.textoSecundario),
                          onPressed: () => context.read<AlmacenProvider>().eliminarInsumo(insumo.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
