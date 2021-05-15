import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';




Future<List<Word>> words(bool all) async {
  // Get a reference to the database.
  Future<Database> database = getDatabasesPath().then((String path) {
    return openDatabase(join(path, 'words_database.db'),
      onCreate: (db, version) {
        return db.execute( "CREATE TABLE words( wordsId INTEGER PRIMARY KEY, word_1 TEXT, word_2 TEXT, wordLg_1 TEXT, wordLg_2 TEXT, wordTime INTEGER, learnt BIT)", );
      },
      version: 2,);
  });
  final Database db = await database;

  // Query the table for all The words.
  final List<Map<String, dynamic>> maps = await db.query('words',);


  // Convert the List<Map<String, dynamic> into a List<word>.

  if(all) {
    return List.generate(maps.length, (i) {
      return Word(
        wordsId: maps[i]['wordId'],
        word_1: maps[i]["word_1"],
        word_2: maps[i]["word_2"],
        wordLg_1: maps[i]["wordLg_1"],
        wordLg_2: maps[i]["wordLg_2"],
        wordTime: maps[i]["wordTime"],
        learnt: maps[i]["learnt"],
      );
    });
  }

  List<Word> wordsList = [];
  for(int i=0; i<maps.length; i++){
    Word iword= Word(
      wordsId: maps[i]['wordId'],
      word_1: maps[i]["word_1"],
      word_2: maps[i]["word_2"],
      wordLg_1: maps[i]["wordLg_1"],
      wordLg_2: maps[i]["wordLg_2"],
      wordTime: maps[i]["wordTime"],
      learnt: maps[i]["learnt"],
    );

    if(maps[i]['wordUploaded']!=0)
      wordsList.add(iword);
  }
  return wordsList;

}

Future<void> insertWord(Word word) async {
  // Get a reference to the database.
  print("insert0");
  final Future<Database> database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'words_database.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) {
      return db.execute( "CREATE TABLE words( wordsId INTEGER PRIMARY KEY, word_1 TEXT, word_2 TEXT, wordLg_1 TEXT, wordLg_2 TEXT, wordTime INTEGER, learnt BIT)", );

    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 2,
  );

  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query('words');
  word = Word(wordsId: maps.length, word_1: word.word_1, word_2: word.word_2, wordLg_1: word.wordLg_1, wordLg_2: word.wordLg_2, wordTime: word.wordTime, learnt: word.learnt);

  // Insert the word into the correct table. Also specify the
  // multiple times, it replaces the previous data.
  await db.insert(
    'words',
    word.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  print("insert1");

}

Future<void> updateWord(Word word) async {
  // Get a reference to the database.
  Future<Database> database = getDatabasesPath().then((String path) {
    return openDatabase(join(path, 'words_database.db'),
      onCreate: (db, version) {
        return db.execute( "CREATE TABLE words( wordsId INTEGER PRIMARY KEY, word_1 TEXT, word_2 TEXT, wordLg_1 TEXT, wordLg_2 TEXT, wordTime INTEGER, learnt BIT)", );
      },
      version: 2,);
  });
  final db = await database;
  // Update the given word.
  await db.update(
    'words',
    word.toMap(),
    // Ensure that the word has a matching id.
    where: "wordsId = ?",
    whereArgs: [word.wordsId],
  );
}

Future<void> deleteWord(int wordId) async {
  Future<Database> database = getDatabasesPath().then((String path) {
    return openDatabase(join(path, 'words_database.db'),
      onCreate: (db, version) {
        return db.execute( "CREATE TABLE words( wordsId INTEGER PRIMARY KEY, word_1 TEXT, word_2 TEXT, wordLg_1 TEXT, wordLg_2 TEXT, wordTime INTEGER, learnt BIT)", );
      },
      version: 2,);
  });
  // Get a reference to the database.
  final db = await database;

  await db.delete(
    'words',
    where: "wordsId = ?",
    whereArgs: [wordId],
  );
}

class Word{
  final int wordsId;
  final String word_1;
  final String word_2;
  final String wordLg_1;
  final String wordLg_2;
  final int wordTime;
  final bool learnt;
  Word({this.wordsId, this.word_1, this.word_2, this.wordLg_1, this.wordLg_2, this.wordTime, this.learnt});

  Map<String, dynamic> toMap() {
    return {
      "wordsId": wordsId,
      "word_1": word_1,
      "word_2": word_2,
      "wordLg_1": wordLg_1,
      "wordLg_2": wordLg_2,
      "wordTime": wordTime,
      "learnt": learnt,
    };
  }

  // Implement toString to make it easier to see information about
  // @override
  // String toString() {
  //   return 'word{wordId: $wordId, wordstate: $wordstate, wordComment: $wordComment, wordFile: $wordFile, wordTime: $wordTime, wordLatitude: $wordLatitude, wordLongitude: $wordLongitude, wordUploaded: $wordUploaded}';
  // }

}