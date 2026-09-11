import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/categorias_provider.dart';
import '../models/receta.dart';
import '../theme/app_theme.dart';

class AjustesCategoriaScreen extends StatelessWidget {
  const AjustesCategoriaScreen({super.key});

  void _nuevaCategoriaDialog(BuildContext context) {
    final nombreCtrl = TextEditingController();
    String? imagenPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: StatefulBuilder(builder: (ctx, setModalState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nueva categoría', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final archivo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                    if (archivo != null) setModalState(() => imagenPath = archivo.path);
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.tarjeta,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divisor),
                      image: imagenPath != null
                          ? DecorationImage(image: FileImage(File(imagenPath!)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: imagenPath == null
                        ? const Center(child: Icon(Icons.add_photo_alternate_outlined, color: AppColors.textoSecundario, size: 32))
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre de la categoría')),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nombreCtrl.text.trim().isEmpty) return;
                      await context.read<CategoriasProvider>().agregarCategoria(nombreCtrl.text.trim(), imagenPath);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Guardar categoría'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriasProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.acentoMenta,
        onPressed: () => _nuevaCategoriaDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Por defecto', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...categoriasPorDefecto.map((c) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(leading: const Icon(Icons.folder_outlined), title: Text(c)),
              )),
          const SizedBox(height: 16),
          Text('Personalizadas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (provider.personalizadas.isEmpty)
            Text('Todavía no creaste ninguna.', style: Theme.of(context).textTheme.bodyMedium)
          else
            ...provider.personalizadas.map((c) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: c.imagenPath != null
                        ? CircleAvatar(backgroundImage: FileImage(File(c.imagenPath!)))
                        : const CircleAvatar(child: Icon(Icons.folder_outlined)),
                    title: Text(c.nombre),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.textoSecundario),
                      onPressed: () => context.read<CategoriasProvider>().eliminarCategoria(c),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
