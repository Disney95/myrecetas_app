import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/receta.dart';
import '../models/insumo.dart';
import '../models/categoria_custom.dart';

class DBHelper {
  static final DBHelper _instancia = DBHelper._interno();
  factory DBHelper() => _instancia;
  DBHelper._interno();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'recetas_app.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _crearTablasV1(db);
        await _crearTablasV2(db);
        await _crearTablasV3(db);
        await _sembrarCategoriasPorDefecto(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _crearTablasV2(db);
        }
        if (oldVersion < 3) {
          await _migrarV3(db);
        }
        await _sembrarCategoriasPorDefecto(db);
      },
    );
  }

  Future<void> _crearTablasV1(Database db) async {
    await db.execute('''
      CREATE TABLE recetas (
        id TEXT PRIMARY KEY,
        nombre TEXT,
        categoria TEXT,
        imagenPath TEXT,
        tiempoPreparacion INTEGER,
        tiempoCoccion INTEGER,
        porciones REAL,
        ingredientes TEXT,
        pasos TEXT,
        costosIndirectosPorcentaje REAL,
        margenGanancia REAL,
        fechaCreacion TEXT
      )
    ''');
  }

  Future<void> _crearTablasV2(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS insumos (
        id TEXT PRIMARY KEY,
        nombre TEXT,
        cantidadComprada REAL,
        unidad TEXT,
        costoTotal REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categorias (
        id TEXT PRIMARY KEY,
        nombre TEXT,
        imagenPath TEXT
      )
    ''');
  }

  /// v3: las categorías "por defecto" pasan a vivir también en la tabla
  /// (para poder editarles nombre/imagen) y se agrega un orden estable.
  /// Los insumos guardan además la moneda original con la que se cargó
  /// el costo, para poder mostrarla sin perder el costo ya convertido a CUP.
  Future<void> _crearTablasV3(Database db) async {
    await db.execute(
        'ALTER TABLE categorias ADD COLUMN orden INTEGER DEFAULT 0');
    await db.execute(
        "ALTER TABLE insumos ADD COLUMN moneda TEXT DEFAULT 'cup'");
    await db.execute(
        'ALTER TABLE insumos ADD COLUMN costoOriginal REAL');
    await db.execute(
        'UPDATE insumos SET costoOriginal = costoTotal WHERE costoOriginal IS NULL');
  }

  Future<void> _migrarV3(Database db) async {
    final columnasCategorias = await db.rawQuery('PRAGMA table_info(categorias)');
    final tieneOrden = columnasCategorias.any((c) => c['name'] == 'orden');
    if (!tieneOrden) {
      await db.execute('ALTER TABLE categorias ADD COLUMN orden INTEGER DEFAULT 0');
    }
    final columnasInsumos = await db.rawQuery('PRAGMA table_info(insumos)');
    if (!columnasInsumos.any((c) => c['name'] == 'moneda')) {
      await db.execute("ALTER TABLE insumos ADD COLUMN moneda TEXT DEFAULT 'cup'");
    }
    if (!columnasInsumos.any((c) => c['name'] == 'costoOriginal')) {
      await db.execute('ALTER TABLE insumos ADD COLUMN costoOriginal REAL');
      await db.execute(
          'UPDATE insumos SET costoOriginal = costoTotal WHERE costoOriginal IS NULL');
    }
  }

  /// Inserta las categorías por defecto (Postres/Dulces, Salados/Comidas,
  /// Bebidas) en la tabla si todavía no existen, para que queden editables
  /// como cualquier otra categoría (nombre e imagen).
  Future<void> _sembrarCategoriasPorDefecto(Database db) async {
    final existeTodas = await db.query('categorias',
        where: 'id = ?', whereArgs: ['todas'], limit: 1);
    if (existeTodas.isEmpty) {
      await db.insert(
          'categorias',
          CategoriaCustom(id: 'todas', nombre: 'Todas', orden: -1).toMap());
    }
    for (var i = 0; i < categoriasPorDefecto.length; i++) {
      final nombre = categoriasPorDefecto[i];
      final existentes = await db.query('categorias',
          where: 'nombre = ?', whereArgs: [nombre], limit: 1);
      if (existentes.isEmpty) {
        await db.insert(
            'categorias',
            CategoriaCustom(
              id: 'default_$i',
              nombre: nombre,
              orden: i,
            ).toMap());
      }
    }
  }

  // ---- CRUD Recetas ----
  Future<void> guardarReceta(Receta receta) async {
    final db = await database;
    await db.insert('recetas', receta.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Receta>> obtenerRecetas() async {
    final db = await database;
    final maps = await db.query('recetas', orderBy: 'fechaCreacion DESC');
    return maps.map((m) => Receta.fromMap(m)).toList();
  }

  Future<void> eliminarReceta(String id) async {
    final db = await database;
    await db.delete('recetas', where: 'id = ?', whereArgs: [id]);
  }

  // ---- CRUD Insumos (almacén) ----
  Future<void> guardarInsumo(Insumo insumo) async {
    final db = await database;
    await db.insert('insumos', insumo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Insumo>> obtenerInsumos() async {
    final db = await database;
    final maps = await db.query('insumos', orderBy: 'nombre ASC');
    return maps.map((m) => Insumo.fromMap(m)).toList();
  }

  Future<void> eliminarInsumo(String id) async {
    final db = await database;
    await db.delete('insumos', where: 'id = ?', whereArgs: [id]);
  }

  // ---- CRUD Categorías ----
  Future<void> guardarCategoria(CategoriaCustom categoria) async {
    final db = await database;
    await db.insert('categorias', categoria.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CategoriaCustom>> obtenerCategorias() async {
    final db = await database;
    final maps = await db.query('categorias', orderBy: 'orden ASC');
    return maps.map((m) => CategoriaCustom.fromMap(m)).toList();
  }

  Future<void> eliminarCategoria(String id) async {
    final db = await database;
    await db.delete('categorias', where: 'id = ?', whereArgs: [id]);
  }
}
