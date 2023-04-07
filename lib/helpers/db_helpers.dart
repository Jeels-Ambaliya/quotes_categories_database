import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/quotes.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper dbHelper = DBHelper._();

  Database? db;

  //Create Database
  Future<void> initDB() async {
    var directory = await getDatabasesPath();
    String path = join(directory, "demo.db");

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int ver) async {
        String query_text =
            "CREATE TABLE IF NOT EXISTS tbl_text(Quote TEXT NOT NULL);";
        String query_bg =
            "CREATE TABLE IF NOT EXISTS tbl_background(Image BLOB NOT NULL);";
        String query_fav =
            "CREATE TABLE IF NOT EXISTS tbl_fav(Image STRING NOT NULL,Quote TEXT NOT NULL,Family TEXT NOT NULL);";

        await db.execute(query_text);
        await db.execute(query_bg);
        await db.execute(query_fav);
      },
    );
  }

  //Create Table
  Future<int> insertText({required Quote quote}) async {
    await initDB();

    String query = "INSERT INTO tbl_text(Quote) VALUES(?);";
    List args = [quote.Quote_Text];

    return await db!
        .rawInsert(query, args); // return on integer => inserted record's id
  }

  Future<int> insertFav({required Fav fav}) async {
    await initDB();

    String query = "INSERT INTO tbl_fav(Image, Quote, Family) VALUES(?, ?, ?);";
    List args = [fav.Image, fav.Quote_Text, fav.Family];

    return await db!
        .rawInsert(query, args); // return on integer => inserted record's id
  }

  Future<int> insertBackground({required Background background}) async {
    await initDB();

    String query = "INSERT INTO tbl_background(Image) VALUES(?);";
    List args = [background.Image];

    return await db!
        .rawInsert(query, args); // return on integer => inserted record's id
  }

  //Fetch All Data
  Future<List<Background>> fetchAllBackground() async {
    await initDB();

    String query = "SELECT * FROM tbl_background;";

    List<Map<String, dynamic>> allRecords = await db!.rawQuery(query);

    List<Background> allQuotes =
        allRecords.map((e) => Background.fromMap(data: e)).toList();

    return allQuotes;
  }

  Future<List<Quote>> fetchAllQuote() async {
    await initDB();

    String query = "SELECT * FROM tbl_text;";

    List<Map<String, dynamic>> allRecords = await db!.rawQuery(query);

    List<Quote> allQuotes =
        allRecords.map((e) => Quote.fromMap(data: e)).toList();

    return allQuotes;
  }

  Future<List<Fav>> fetchAllFav() async {
    await initDB();

    String query = "SELECT * FROM tbl_fav;";

    List<Map<String, dynamic>> allRecords = await db!.rawQuery(query);

    List<Fav> allFav = allRecords.map((e) => Fav.fromMap(data: e)).toList();

    return allFav;
  }
}
