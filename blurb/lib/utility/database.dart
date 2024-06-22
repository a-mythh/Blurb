import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DictionaryDatabase {
  static final DictionaryDatabase instance = DictionaryDatabase._init();
  static Database? _database;

  /* TABLE NAMES */
  static const String wordsTable = 'words',
      partsOfSpeechTable = 'parts_of_speech',
      meaningsTable = 'meanings',
      examplesTable = 'examples';

  DictionaryDatabase._init();

  /* FIND DATABASE */
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB(filePath: 'blurb.db');

    return _database!;
  }

  /* INITIALIZE DATABASE */
  Future<Database> _initDB({required String filePath}) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    try {
      final db = await openDatabase(path, version: 1, onCreate: _createDB);
      print('Finished initializing database.');
      return db;
    } catch (e) {
      print('Error initializing database: $e');
      throw Exception('Database initialization failed');
    }
  }

  /* CREATE DATABASE */
  Future _createDB(Database db, int version) async {
    try {
      await db.execute('''
      CREATE TABLE $wordsTable(
        word_id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        phonetics TEXT NOT NULL,
        audio TEXT NOT NULL,
        synonyms TEXT  NOT NULL,
        antonyms TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
      ''');
      await db.execute('''
      CREATE TABLE $partsOfSpeechTable(
        part_of_speech_id INTEGER PRIMARY KEY AUTOINCREMENT,
        part_of_speech TEXT NOT NULL,
        word_id INTEGER,
        FOREIGN KEY(word_id) REFERENCES $wordsTable(word_id)
      );
      ''');
      await db.execute('''
      CREATE TABLE $meaningsTable(
        meaning_id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER,
        part_of_speech_id INTEGER,
        meaning TEXT NOT NULL,
        FOREIGN KEY(word_id) REFERENCES $wordsTable(word_id),
        FOREIGN KEY(part_of_speech_id) REFERENCES $partsOfSpeechTable(part_of_speech_id)
      );
      ''');
      await db.execute('''
      CREATE TABLE $examplesTable(
        example_id INTEGER PRIMARY KEY AUTOINCREMENT,
        meaning_id INTEGER,
        example TEXT NOT NULL,
        FOREIGN KEY(meaning_id) REFERENCES $meaningsTable(meaning_id)
      );
      ''');
      print('Finished creating tables.');
    } catch (e) {
      print('Error creating database table: $e');
      throw Exception('Database table creation failed');
    }
  }

  /* ADD WORD TO DATABASE */
  Future<Map<String, dynamic>> addWord({
    required String word,
    required String phonetics,
    required String audio,
    required Map<String, List<Map<String, String>>> partsOfSpeechAndMeanings,
    required String synonyms,
    required String antonyms,
  }) async {
    final db = await instance.database;

    try {
      late int wordId;
      late Object createdAt;

      await db.transaction((txn) async {
        wordId = await txn.insert(wordsTable, {
          'word': word,
          'phonetics': phonetics,
          'audio': audio,
          'synonyms': synonyms,
          'antonyms': antonyms,
        });

        final insertedRow = await txn.query(
          wordsTable,
          where: 'word_id = ?',
          whereArgs: [wordId],
        );

        createdAt = insertedRow.first['created_at']!;

        // Iterate over the parts of speech
        for (var posEntry in partsOfSpeechAndMeanings.entries) {
          String partOfSpeech = posEntry.key;
          List<Map<String, String>> meaningsWithExamplesList = posEntry.value;

          // Insert the part of speech and get its id
          final partOfSpeechId = await txn.insert(partsOfSpeechTable, {
            'part_of_speech': partOfSpeech,
            'word_id': wordId,
          });

          // Iterate over the list of meanings with examples
          for (Map<String, String> meaningWithExample
              in meaningsWithExamplesList) {
            var meaningKeys = meaningWithExample.keys;
            String definition = meaningWithExample[meaningKeys.first]!;
            String example = meaningWithExample[meaningKeys.last]!;

            // Insert the meaning and get its id
            final meaningId = await txn.insert(meaningsTable, {
              'word_id': wordId,
              'part_of_speech_id': partOfSpeechId,
              'meaning': definition,
            });

            // Insert the example
            await txn.insert(examplesTable, {
              'meaning_id': meaningId,
              'example': example,
            });
          }
        }
      });

      print('Added word to database');
      Map<String, dynamic> result = {
        'word_id': wordId,
        'word': word,
        'created_at': createdAt,
      };
      return result;
    } on DatabaseException catch (e) {
      print('DatabaseException: $e');
      throw Exception('Failed to add word: $e');
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to add word: $e');
    }
  }

  /* FIND WORD BY NAME */
  Future<Map<String, dynamic>> findWord({required String wordName}) async {
    final db = await instance.database;
    Map<String, dynamic> wordData = {};

    try {
      final List<Map<String, dynamic>> words = await db.query(
        wordsTable,
        where: 'word = ?',
        whereArgs: [wordName],
      );

      if (words.isNotEmpty) {
        wordData['word'] = words.first['word'];
        wordData['saved_on'] = words.first['created_at'];
        wordData['phonetics'] = [{
          'text': words.first['phonetics'],
          'audio': words.first['audio'],
        }];
        wordData['thesaurus'] = {
          'synonyms': words.first['synonyms'].toString().split(', '),
          'antonyms': words.first['antonyms'].toString().split(', '),
        };
        wordData['thesaurus']['synonyms'].remove('');
        wordData['thesaurus']['antonyms'].remove('');

        // Get parts of speech and their meanings with examples
        final List<Map<String, dynamic>> partsOfSpeechList = await db.query(
          partsOfSpeechTable,
          where: 'word_id = ?',
          whereArgs: [words.first['word_id']],
        );

        Map<String, List<Map<String, String>>> partsOfSpeechAndMeanings = {};
        for (var partOfSpeech in partsOfSpeechList) {
          String posName = partOfSpeech['part_of_speech'];

          // Get meanings and examples for this part of speech
          final List<Map<String, dynamic>> meaningsList = await db.query(
            meaningsTable,
            where: 'part_of_speech_id = ?',
            whereArgs: [partOfSpeech['part_of_speech_id']],
          );

          List<Map<String, String>> meaningsWithExamples = [];
          for (var meaning in meaningsList) {
            // Get example for this meaning
            final List<Map<String, dynamic>> examplesList = await db.query(
              examplesTable,
              where: 'meaning_id = ?',
              whereArgs: [meaning['meaning_id']],
            );

            if (examplesList.isNotEmpty) {
              meaningsWithExamples.add({
                'definition': meaning['meaning'],
                'usage': examplesList.first['example'],
              });
            }
          }

          if (meaningsWithExamples.isNotEmpty) {
            partsOfSpeechAndMeanings[posName] = meaningsWithExamples;
          }
        }

        if (partsOfSpeechAndMeanings.isNotEmpty) {
          wordData['meanings'] = partsOfSpeechAndMeanings;
        }
      }

      print('Found the word.');
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to find word: $e');
    }

    return wordData;
  }

  /* GET ALL WORDS */
  Future<List<Map<String, dynamic>>> getAllWords() async {
    final db = await instance.database;
    List<Map<String, dynamic>> allWords = [];

    try {
      allWords = await db.query(
        'words',
        columns: ['word_id', 'word', 'created_at'],
      );
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to get all words with creation date: $e');
    }

    print('Got all the words.');
    return allWords;
  }

  /* DELETE WORD */
  Future<bool> deleteWord({required String word}) async {
    final db = await instance.database;

    try {
      // Start a transaction
      await db.transaction((txn) async {
        // Get the word id
        final List<Map<String, dynamic>> words = await txn.query(
          'words',
          columns: ['word_id'],
          where: 'word = ?',
          whereArgs: [word],
        );

        if (words.isNotEmpty) {
          final int wordId = words.first['word_id'];

          // Delete examples
          await txn.delete(
            'examples',
            where:
                'meaning_id IN (SELECT meaning_id FROM meanings WHERE word_id = ?)',
            whereArgs: [wordId],
          );

          // Delete meanings
          await txn.delete(
            'meanings',
            where: 'word_id = ?',
            whereArgs: [wordId],
          );

          // Delete parts of speech
          await txn.delete(
            'parts_of_speech',
            where: 'word_id = ?',
            whereArgs: [wordId],
          );

          // Finally, delete the word itself
          await txn.delete(
            'words',
            where: 'word_id = ?',
            whereArgs: [wordId],
          );
        }
      });

      print('Deleted the word');

      return true;
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to delete word: $e');
    }
  }

  /* CLOSE DATABASE */
  Future close() async {
    final db = await instance.database;

    try {
      db.close();
    } catch (e) {
      print('Error closing database: $e');
    }
  }
}
