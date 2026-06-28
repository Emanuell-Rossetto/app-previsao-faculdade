import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:previsao_faculdade/models/city_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'weather_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE cities ADD COLUMN lat REAL');
          await db.execute('ALTER TABLE cities ADD COLUMN lon REAL');
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cities(
        id INTEGER PRIMARY KEY,
        nome TEXT,
        uf TEXT,
        lat REAL,
        lon REAL,
        is_current_location INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertCity(CityModel city, {bool isCurrentLocation = false, double? lat, double? lon}) async {
    final db = await database;
    
    if (isCurrentLocation) {
      // Clear previous current location
      await db.update('cities', {'is_current_location': 0}, where: 'is_current_location = ?', whereArgs: [1]);
    }

    // Check if city already exists (only for manual cities, current location is always updated)
    if (!isCurrentLocation) {
      final List<Map<String, dynamic>> maps = await db.query(
        'cities',
        where: 'nome = ? AND uf = ?',
        whereArgs: [city.nome, city.microrregiao?.mesorregiao?.uF?.sigla ?? ''],
      );

      if (maps.isNotEmpty) {
        return maps[0]['id'];
      }
    } else {
      // For current location, we might want to delete the old one to avoid duplicates if name changed
      await db.delete('cities', where: 'is_current_location = ?', whereArgs: [1]);
    }

    return await db.insert('cities', {
      'id': isCurrentLocation ? null : city.id,
      'nome': city.nome,
      'uf': city.microrregiao?.mesorregiao?.uF?.sigla ?? '',
      'lat': lat,
      'lon': lon,
      'is_current_location': isCurrentLocation ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getSavedCities() async {
    final db = await database;
    return await db.query('cities', orderBy: 'is_current_location DESC, nome ASC');
  }

  Future<void> deleteCity(int id) async {
    final db = await database;
    await db.delete('cities', where: 'id = ?', whereArgs: [id]);
  }
}
