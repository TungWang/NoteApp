import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'note.dart';

class Db {
  static const String notes = 'notes';
  Database _database;

  Future<Database> getDatabase() async {
    if (_database != null) {
      return _database;
    }

    _database = await openDatabase(
      join(
        await getDatabasesPath(),
        'note_database.db',
      ),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $notes(id TEXT PRIMARY KEY, content TEXT, color INTEGER, date TEXT)",
        );
      },
      version: 1,
    );

    return _database;
  }

  Future<void> insertNote(Note note) async {
    final Database db = await getDatabase();

    await db.insert(
      notes,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> queryNotes() async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(notes);

    return List.generate(maps.length, (i) {
      return Note(
        content: maps[i]['content'],
        date: maps[i]['date'],
        color: maps[i]['color'],
        id: maps[i]['id'],
      );
    });
  }

  Future<void> updateNote(Note note) async {
    final db = await getDatabase();

    await db.update(
      notes,
      note.toMap(),
      where: "id = ?",
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(Note note) async {
    final db = await getDatabase();

    await db.delete(
      notes,
      where: "id = ?",
      whereArgs: [note.id],
    );
  }
}
