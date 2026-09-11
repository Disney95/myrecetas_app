import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recetas_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/receta_card.dart';
import 'detalle_receta_screen.dart';

class MisRecetasScreen extends StatefulWidget {
  const MisRecetasScreen({super.key});

  @override
  State<MisRecetasScreen> createState() => _MisRecetasScreenState();
}

class _MisRecetasScreenState extends State<MisRecetasScreen> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecetasProvider>();
    final recetas = provider.buscar(_busqueda);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Recetas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar receta...',
                prefixIcon: Icon(Icons.search, color: AppColors.textoSecundario),
              ),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
          ),
          Expanded(
            child: provider.cargando
                ? const Center(child: CircularProgressIndicator())
                : recetas.isEmpty
                    ? Center(
                        child: Text('No se encontraron recetas',
                            style: Theme.of(context).textTheme.bodyMedium))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: recetas.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey(recetas[i].id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.red),
                            ),
                            confirmDismiss: (_) => showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Eliminar receta'),
                                content: Text('¿Eliminar "${recetas[i].nombre}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
                                ],
                              ),
                            ),
                            onDismissed: (_) => provider.eliminarReceta(recetas[i].id),
                            child: RecetaCard(
                              receta: recetas[i],
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => DetalleRecetaScreen(receta: recetas[i]))),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
