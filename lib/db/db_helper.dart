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
      version: 2,
      onCreate: (db, version) async {
        await _crearTablasV1(db);
        await _crearTablasV2(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _crearTablasV2(db);
        }
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

  // ---- CRUD Categorías personalizadas ----
  Future<void> guardarCategoria(CategoriaCustom categoria) async {
    final db = await database;
    await db.insert('categorias', categoria.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CategoriaCustom>> obtenerCategorias() async {
    final db = await database;
    final maps = await db.query('categorias', orderBy: 'nombre ASC');
    return maps.map((m) => CategoriaCustom.fromMap(m)).toList();
  }

  Future<void> eliminarCategoria(String id) async {
    final db = await database;
    await db.delete('categorias', where: 'id = ?', whereArgs: [id]);
  }
}
