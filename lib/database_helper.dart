import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'neokids.db');

    print("Ruta de la base de datos: $path");

    return await openDatabase(
      path,
      version: 3, // Incrementar versión para realizar migración
      onCreate: (db, version) async {
        print("Creando base de datos en: $path");

        await db.execute(''' 
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            apellido TEXT NOT NULL,
            edad INTEGER NOT NULL,
            genero TEXT NOT NULL,
            alergias TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE recordatorios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            cantidad TEXT NOT NULL,
            id_user INTEGER NOT NULL,
            frecuencia INTEGER NOT NULL,  -- Cambiado a INTEGER
            activo INTEGER DEFAULT 0,
            dias_medicacion INTEGER DEFAULT 1, -- Cambiado a INTEGER
            hora_inicio TEXT, -- Hora de inicio en formato HH:mm
            recordar INTEGER DEFAULT 0, -- 0 para "Cuando sea la hora", 1 para "5 minutos antes"
            FOREIGN KEY (id_user) REFERENCES usuarios (id)
          )
        ''');

        print("Base de datos creada exitosamente.");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Añadir las nuevas columnas a la tabla 'recordatorios'
          await db.execute(''' 
            ALTER TABLE recordatorios ADD COLUMN dias_medicacion INTEGER DEFAULT 1
          ''');
          await db.execute(''' 
            ALTER TABLE recordatorios ADD COLUMN hora_inicio TEXT
          ''');
          await db.execute(''' 
            ALTER TABLE recordatorios ADD COLUMN recordar INTEGER DEFAULT 0
          ''');
          print("Nuevas columnas añadidas a la tabla 'recordatorios'.");
        }
      },
    );
  }

  // Métodos CRUD para usuarios
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('usuarios', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('usuarios');
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'usuarios',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos CRUD para recordatorios
  Future<int> insertReminder(Map<String, dynamic> reminder) async {
    final db = await database;
    return await db.insert('recordatorios', reminder);
  }

  Future<List<Map<String, dynamic>>> getReminders() async {
    final db = await database;
    return await db.query('recordatorios');
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete('recordatorios', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getDetailedReminders() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT recordatorios.*, usuarios.nombre AS asignado
      FROM recordatorios
      JOIN usuarios ON recordatorios.id_user = usuarios.id
    ''');
  }

  Future<int> updateReminderStatus(int id, Map<String, dynamic> reminder) async {
  final db = await database;
  return await db.update(
    'recordatorios',
    reminder,
    where: 'id = ?',
    whereArgs: [id],
  );
}

}
