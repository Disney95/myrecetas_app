import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/categorias_provider.dart';
import '../models/categoria_custom.dart';
import '../theme/app_theme.dart';

class AjustesCategoriaScreen extends StatelessWidget {
  const AjustesCategoriaScreen({super.key});

  void _editarCategoriaDialog(BuildContext context, {CategoriaCustom? existente}) {
    final nombreCtrl = TextEditingController(text: existente?.nombre ?? '');
    String? imagenPath = existente?.imagenPath;

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
                Text(existente == null ? 'Nueva categoría' : 'Editar categoría',
                    style: Theme.of(context).textTheme.titleMedium),
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
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                                  onPressed: () async {
                                    final picker = ImagePicker();
                                    final archivo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                                    if (archivo != null) setModalState(() => imagenPath = archivo.path);
                                  },
                                ),
                              ),
                            ),
                          ),
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
                      final provider = context.read<CategoriasProvider>();
                      if (existente == null) {
                        await provider.agregarCategoria(nombreCtrl.text.trim(), imagenPath);
                      } else {
                        await provider.editarCategoria(existente,
                            nombre: nombreCtrl.text.trim(), imagenPath: imagenPath);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(existente == null ? 'Guardar categoría' : 'Guardar cambios'),
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

  void _confirmarEliminar(BuildContext context, CategoriaCustom categoria) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Eliminar "${categoria.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<CategoriasProvider>().eliminarCategoria(categoria);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriasProvider>();
    final categorias = provider.categorias;
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.acentoMenta,
        onPressed: () => _editarCategoriaDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: categorias.isEmpty
          ? Center(
              child: Text('No hay categorías todavía.\nAgregá la primera con el botón +.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: categorias
                  .map((c) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () => _editarCategoriaDialog(context, existente: c),
                          leading: c.imagenPath != null
                              ? CircleAvatar(backgroundImage: FileImage(File(c.imagenPath!)))
                              : const CircleAvatar(child: Icon(Icons.folder_outlined)),
                          title: Text(c.nombre),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.textoSecundario),
                                onPressed: () => _editarCategoriaDialog(context, existente: c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.textoSecundario),
                                onPressed: () => _confirmarEliminar(context, c),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}
