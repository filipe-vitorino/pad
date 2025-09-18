import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sensor_data.dart';
import '../models/device_config.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sensor_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE leituras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dataLeitura INTEGER NOT NULL,
        totalRegistos INTEGER NOT NULL,
        deviceId TEXT,
        latitude REAL,
        longitude REAL

      )
    ''');
    await db.execute('''
      CREATE TABLE registos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        leituraId INTEGER NOT NULL,
        ts INTEGER NOT NULL,
        vazao REAL,
        volume REAL,
        pressao REAL,
        temperatura REAL,
        tds REAL,
        enviadoServidor INTEGER NOT NULL DEFAULT 0, -- 0 = false, 1 = true
        FOREIGN KEY (leituraId) REFERENCES leituras (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Salva uma sincronização completa (uma "leitura") no banco de dados.
  Future<void> saveReading(List<SensorData> logs, DeviceConfig config) async {
    if (logs.isEmpty) return;
    final db = await instance.database;

    final readingData = {
      'dataLeitura': DateTime.now().millisecondsSinceEpoch,
      'totalRegistos': logs.length,
      'deviceId': config.deviceId,
      'latitude': config.gps.latitude,
      'longitude': config.gps.longitude,
    };
    final readingId = await db.insert('leituras', readingData);

    // 2. Itera sobre cada registo e o insere na tabela 'registos'
    // Usamos um batch para otimizar a performance
    Batch batch = db.batch();
    for (var log in logs) {
      batch.insert('registos', {
        'leituraId': readingId,
        'ts': log.ts ?? 0,
        'vazao': log.vazao,
        'volume': log.volume,
        'pressao': log.pressao,
        'temperatura': log.temperatura,
        'tds': log.tds,
      });
    }
    await batch.commit(noResult: true);
    print(
      "✅ Leitura #$readingId com ${logs.length} registos salva no banco de dados.",
    );
  }

  /// Busca todos os resumos de leituras.
  Future<List<Map<String, dynamic>>> getReadingsSummary() async {
    final db = await instance.database;
    // Ordena da mais recente para a mais antiga
    return await db.query('leituras', orderBy: 'dataLeitura DESC');
  }

  /// Busca todos os registos detalhados de uma leitura específica.
  Future<List<SensorData>> getLogsForReading(int readingId) async {
    final db = await instance.database;
    final maps = await db.query(
      'registos',
      where: 'leituraId = ?',
      whereArgs: [readingId],
    );

    return maps.map((json) => SensorData.fromJson(json)).toList();
  }

  Future<List<SensorData>> getUnsyncedLogs() async {
    final db = await instance.database;
    final maps = await db.query(
      'registos',
      where: 'enviadoServidor = ?',
      whereArgs: [0], // Apenas os que têm a flag 0 (false)
    );
    if (maps.isEmpty) return [];
    return maps.map((json) => SensorData.fromJson(json)).toList();
  }

  /// Marca uma lista de registos como "enviados" no banco de dados.
  Future<void> markLogsAsSynced(List<int> logIds) async {
    if (logIds.isEmpty) return;
    final db = await instance.database;

    // Usamos um batch para executar múltiplas atualizações de uma só vez (muito mais rápido)
    Batch batch = db.batch();
    for (int id in logIds) {
      batch.update(
        'registos',
        {'enviadoServidor': 1}, // Define a flag para 1 (true)
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
    print("${logIds.length} registos marcados como sincronizados.");
  }
}
