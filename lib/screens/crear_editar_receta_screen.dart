import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/receta.dart';
import '../models/ingrediente.dart';
import '../providers/recetas_provider.dart';
import '../providers/almacen_provider.dart';
import '../providers/categorias_provider.dart';
import '../theme/app_theme.dart';
import '../utils/unidades.dart';

class CrearEditarRecetaScreen extends StatefulWidget {
  final Receta? recetaExistente;
  const CrearEditarRecetaScreen({super.key, this.recetaExistente});

  @override
  State<CrearEditarRecetaScreen> createState() => _CrearEditarRecetaScreenState();
}

class _CrearEditarRecetaScreenState extends State<CrearEditarRecetaScreen> {
  final _nombreCtrl = TextEditingController();
  final _porcionesCtrl = TextEditingController(text: '1');
  final _prepCtrl = TextEditingController(text: '0');
  final _coccionCtrl = TextEditingController(text: '0');
  final _urlImagenCtrl = TextEditingController();

  String _categoria = categoriasPorDefecto.first;
  String? _imagenPath;
  double _indirectos = 15;
  double _margen = 50;
  final List<Ingrediente> _ingredientes = [];
  final List<String> _pasos = [];

  bool get _esEdicion => widget.recetaExistente != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recetaExistente;
    if (r != null) {
      _nombreCtrl.text = r.nombre;
      _porcionesCtrl.text = r.porciones.toString();
      _prepCtrl.text = r.tiempoPreparacion.toString();
      _coccionCtrl.text = r.tiempoCoccion.toString();
      _categoria = r.categoria;
      _imagenPath = r.imagenPath;
      _indirectos = r.costosIndirectosPorcentaje;
      _margen = r.margenGanancia;
      _ingredientes.addAll(r.ingredientes.map((i) => Ingrediente.fromMap(i.toMap())));
      _pasos.addAll(r.pasos);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _porcionesCtrl.dispose();
    _prepCtrl.dispose();
    _coccionCtrl.dispose();
    _urlImagenCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirImagen() async {
    final picker = ImagePicker();
    final archivo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (archivo != null) {
      setState(() => _imagenPath = archivo.path);
    }
  }

  void _usarUrlImagen() {
    // Al pegar desde otras apps a veces llegan espacios o caracteres
    // invisibles (comillas curvas, saltos de línea, zero-width space) que
    // hacían fallar la validación aunque la URL fuera correcta.
    var url = _urlImagenCtrl.text.trim();
    url = url.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u00A0]'), '');
    url = url.replaceAll('"', '').replaceAll("'", '');
    if (url.isEmpty) return;

    final uri = Uri.tryParse(url);
    final valida = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!valida) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Esa URL no es válida. Debe empezar con http:// o https://')));
      return;
    }
    setState(() {
      _imagenPath = url;
      _urlImagenCtrl.clear();
    });
    FocusScope.of(context).unfocus();
  }

  double get _costoMateriaPrima =>
      _ingredientes.fold(0.0, (s, i) => s + i.costoCalculado);

  double get _porciones => double.tryParse(_porcionesCtrl.text) ?? 1;

  double get _costoTotal => _costoMateriaPrima * (1 + _indirectos / 100);
  double get _costoPorPorcion => _porciones > 0 ? _costoTotal / _porciones : 0;
  double get _precioVenta => _costoPorPorcion * (1 + _margen / 100);

  Future<void> _agregarIngredienteDialog() async {
    final nombreCtrl = TextEditingController();
    final cantCtrl = TextEditingController();
    String unidad = 'g';
    final precioCtrl = TextEditingController();
    final cantCompraCtrl = TextEditingController(text: '1');
    final almacenProvider = context.read<AlmacenProvider>();
    bool autoDelAlmacen = false;
    double? costoCalculadoPreview;

    void recalcularPreview(StateSetter setModalState) {
      final cantidad = double.tryParse(cantCtrl.text) ?? 0;
      final precio = double.tryParse(precioCtrl.text) ?? 0;
      final cantCompra = double.tryParse(cantCompraCtrl.text) ?? 1;
      setModalState(() {
        costoCalculadoPreview = (cantidad > 0 && precio > 0 && cantCompra > 0)
            ? (precio / cantCompra) * cantidad
            : null;
      });
    }

    void intentarAutocompletar(StateSetter setModalState) {
      final nombre = nombreCtrl.text.trim();
      if (nombre.isEmpty) return;
      final insumo = almacenProvider.buscarPorNombre(nombre, unidad);
      if (insumo != null) {
        final precioUnitario = insumo.costoPorUnidadBase * UnidadesUtil.aBase(unidad, 1);
        cantCompraCtrl.text = '1';
        precioCtrl.text = precioUnitario.toStringAsFixed(4);
        autoDelAlmacen = true;
      } else if (autoDelAlmacen) {
        autoDelAlmacen = false;
      }
      recalcularPreview(setModalState);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: StatefulBuilder(builder: (ctx, setModalState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nuevo ingrediente', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nombreCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Nombre del ingrediente'),
                    onChanged: (_) => intentarAutocompletar(setModalState),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: cantCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Cantidad usada'),
                        onChanged: (_) => recalcularPreview(setModalState),
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
                        onChanged: (v) {
                          unidad = v ?? 'g';
                          intentarAutocompletar(setModalState);
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: autoDelAlmacen
                          ? InputDecorator(
                              decoration: const InputDecoration(labelText: 'Precio'),
                              child: Text(
                                costoCalculadoPreview != null
                                    ? '≈ \$${costoCalculadoPreview!.toStringAsFixed(2)}'
                                    : '—',
                                style: const TextStyle(color: AppColors.acentoMenta, fontWeight: FontWeight.w600),
                              ),
                            )
                          : TextField(
                              controller: precioCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                              decoration: const InputDecoration(labelText: 'Precio'),
                              onChanged: (_) => recalcularPreview(setModalState),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: cantCompraCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Por cantidad'),
                        onChanged: (_) => recalcularPreview(setModalState),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final nombre = nombreCtrl.text.trim();
                        final cantidad = double.tryParse(cantCtrl.text) ?? 0;
                        final precio = double.tryParse(precioCtrl.text) ?? 0;
                        final cantCompra = double.tryParse(cantCompraCtrl.text) ?? 1;
                        if (nombre.isEmpty || cantidad <= 0) return;
                        setState(() {
                          _ingredientes.add(Ingrediente(
                            id: DateTime.now().microsecondsSinceEpoch.toString(),
                            nombre: nombre,
                            cantidad: cantidad,
                            unidad: unidad,
                            precioCompra: precio,
                            cantidadCompra: cantCompra <= 0 ? 1 : cantCompra,
                          ));
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Agregar ingrediente'),
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

  void _agregarPasoDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo paso'),
        content: TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Describí el paso...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _pasos.add(ctrl.text.trim()));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresá el nombre de la receta')));
      return;
    }
    final provider = context.read<RecetasProvider>();
    final receta = Receta(
      id: widget.recetaExistente?.id ?? provider.generarId(),
      nombre: nombre,
      categoria: _categoria,
      imagenPath: _imagenPath,
      tiempoPreparacion: int.tryParse(_prepCtrl.text) ?? 0,
      tiempoCoccion: int.tryParse(_coccionCtrl.text) ?? 0,
      porciones: _porciones,
      ingredientes: _ingredientes,
      pasos: _pasos,
      costosIndirectosPorcentaje: _indirectos,
      margenGanancia: _margen,
      fechaCreacion: widget.recetaExistente?.fechaCreacion,
    );
    await provider.guardarReceta(receta);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta guardada correctamente')));
      if (_esEdicion) Navigator.pop(context);
      else _limpiarFormulario();
    }
  }

  void _limpiarFormulario() {
    setState(() {
      _nombreCtrl.clear();
      _porcionesCtrl.text = '1';
      _prepCtrl.text = '0';
      _coccionCtrl.text = '0';
      _imagenPath = null;
      _indirectos = 15;
      _margen = 50;
      _ingredientes.clear();
      _pasos.clear();
      _categoria = categoriasPorDefecto.first;
    });
  }

  Widget _imagenPreview() {
    if (_imagenPath == null || _imagenPath!.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(color: AppColors.tarjeta, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divisor)),
        child: const Center(child: Icon(Icons.image_outlined, size: 40, color: AppColors.textoSecundario)),
      );
    }
    final img = _imagenPath!.startsWith('http')
        ? Image.network(
            _imagenPath!,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progreso) {
              if (progreso == null) return child;
              return Container(
                height: 160,
                color: AppColors.tarjeta,
                child: const Center(child: CircularProgressIndicator(color: AppColors.acentoMenta)),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: 160,
              decoration: BoxDecoration(color: AppColors.tarjeta, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divisor)),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_outlined, size: 32, color: AppColors.textoSecundario),
                      SizedBox(height: 6),
                      Text('No se pudo cargar la imagen de esa URL',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textoSecundario, fontSize: 12, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text(
                        'Ese enlace no apunta directo a un archivo de imagen (por ejemplo, un enlace de Pinterest a una publicación no funciona). '
                        'Mantén presionada la imagen en el navegador y elige "Copiar dirección de imagen" para obtener el enlace correcto.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textoSecundario, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Image.file(File(_imagenPath!), height: 160, width: double.infinity, fit: BoxFit.cover);
    return ClipRRect(borderRadius: BorderRadius.circular(16), child: img);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Receta' : 'Crear Receta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _imagenPreview(),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _elegirImagen, icon: const Icon(Icons.photo_library_outlined), label: const Text('Galería'))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(
              controller: _urlImagenCtrl,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _usarUrlImagen(),
              decoration: const InputDecoration(labelText: 'O pegar URL de imagen'),
            )),
            const SizedBox(width: 8),
            IconButton(onPressed: _usarUrlImagen, icon: const Icon(Icons.check_circle_outline, color: AppColors.acentoMenta)),
          ]),
          const SizedBox(height: 20),
          TextField(
            controller: _nombreCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nombre de la receta'),
          ),
          const SizedBox(height: 14),
          Consumer<CategoriasProvider>(
            builder: (context, categoriasProvider, _) {
              final nombres = categoriasProvider.nombres;
              if (!nombres.contains(_categoria)) _categoria = nombres.first;
              return DropdownButtonFormField<String>(
                value: _categoria,
                isDense: true,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                ),
                items: nombres
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v ?? _categoria),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: TextField(controller: _prepCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Prep. (min)'))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _coccionCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Cocción (min)'))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _porcionesCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Porciones'), onChanged: (_) => setState(() {}))),
          ]),
          const SizedBox(height: 24),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Ingredientes', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(onPressed: _agregarIngredienteDialog, icon: const Icon(Icons.add, size: 18), label: const Text('Agregar')),
          ]),
          if (_ingredientes.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text('Sin ingredientes todavía', style: Theme.of(context).textTheme.bodyMedium))
          else
            ..._ingredientes.map((i) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('${i.nombre} — ${i.cantidad} ${i.unidad}'),
                    subtitle: Text('Costo: \$${i.costoCalculado.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.textoSecundario),
                      onPressed: () => setState(() => _ingredientes.remove(i)),
                    ),
                  ),
                )),
          const SizedBox(height: 24),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Pasos de preparación', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(onPressed: _agregarPasoDialog, icon: const Icon(Icons.add, size: 18), label: const Text('Agregar')),
          ]),
          if (_pasos.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text('Sin pasos todavía', style: Theme.of(context).textTheme.bodyMedium))
          else
            ..._pasos.asMap().entries.map((e) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.acentoMenta.withOpacity(0.15), child: Text('${e.key + 1}', style: const TextStyle(color: AppColors.acentoMenta, fontWeight: FontWeight.bold))),
                    title: Text(e.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.textoSecundario),
                      onPressed: () => setState(() => _pasos.removeAt(e.key)),
                    ),
                  ),
                )),
          const SizedBox(height: 24),

          Text('Resumen financiero', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _sliderCampo('Costos indirectos', _indirectos, 0, 100, (v) => setState(() => _indirectos = v)),
                  _sliderCampo('Margen de ganancia', _margen, 0, 300, (v) => setState(() => _margen = v)),
                  const Divider(height: 28),
                  _filaResumen('Costo materia prima', _costoMateriaPrima),
                  _filaResumen('Costo total producción', _costoTotal),
                  _filaResumen('Costo por porción', _costoPorPorcion),
                  _filaResumen('Precio de venta sugerido', _precioVenta, destacado: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _guardar, child: Text(_esEdicion ? 'Guardar cambios' : 'Guardar receta')),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sliderCampo(String label, double valor, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text('${valor.toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.acentoMenta, fontWeight: FontWeight.bold)),
        ]),
        Slider(value: valor, min: min, max: max, activeColor: AppColors.acentoMenta, onChanged: onChanged),
      ],
    );
  }

  Widget _filaResumen(String label, double valor, {bool destacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text('\$${valor.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: destacado ? AppColors.exito : AppColors.textoPrincipal, fontSize: destacado ? 17 : 14)),
      ]),
    );
  }
}
