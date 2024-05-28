import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../model/personne.dart';
import '../model/table_util.dart';

class PersonneProvider {
  Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await _initDatabase();
      return _db;
    }
  }

  PersonneProvider._privateConstructor();

  static final PersonneProvider instance = PersonneProvider._privateConstructor();

  _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, DATABASE_NAME);
    return await openDatabase(
      path,
      version: DATABASE_VERSION,
      onCreate: _open,
    );
  }

  Future _open(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $TABLE_PERSONNE (
        $COLONNE_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COLONNE_NOM TEXT,
        $COLONNE_PRENOM TEXT,
        $COLONNE_AGE TEXT)
    ''');
  }

  Future<int?> insert(Personne personne) async {
    Database? db = await instance.db;
    return await db?.insert(TABLE_PERSONNE, personne.toMap());
  }

  Future<Personne?> getPersonne(int id) async {
    Database? db = await instance.db;
    List<Map>? maps = await db?.query(TABLE_PERSONNE,
        columns: [COLONNE_ID, COLONNE_NOM, COLONNE_PRENOM, COLONNE_AGE],
        where: '$COLONNE_ID = ?',
        whereArgs: [id]);

    if (maps != null && maps.isNotEmpty) {
      return Personne.fromMap(maps.first as Map<String, dynamic>);
    }
    return null;
  }

  Future<int?> delete(int id) async {
    Database? db = await instance.db;
    return await db?.delete(TABLE_PERSONNE, where: '$COLONNE_ID = ?', whereArgs: [id]);
  }

  Future close() async => _db?.close();
}