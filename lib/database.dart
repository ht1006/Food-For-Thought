import 'dart:core';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database db;

Future openAppDatabase() async {
  if (db != null) return;

  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, 'app.db');

  if (!(await databaseExists(path))) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
  }

  db = await openDatabase(path, version: 1, onCreate: (db, version) {
    return db.execute('CREATE TABLE owned(name TEXT NOT NULL, '
        'category TEXT NOT NULL, expire DATE)');
  });
}

// Add an ingredient to the 'owned' table
Future addOwnedIngredient(String category, String ingredient) async {
  await db.insert('owned',
      OwnedIngredient(name: ingredient, category: category).toMap());
}

// Removes an ingredient to the 'owned' table
Future removeOwnedIngredient(String ingredient) async {
  await db.delete('owned', where: '"name" = ?', whereArgs: [ingredient]);
}

// Retrieves list of owned ingredients from the given category
Future<List> getOwnedIngredientList(String category) async {
  if (db == null) return [];
  List<Map> result = await db.query('owned', where: '"category" = ?',
      whereArgs: [category], distinct: true);
  return mapToList(result, 'name');
}

Future<List> getAllOwnedIngredients() async {
  List<Map> result = await db.query('owned');
  List<OwnedIngredient> list = [];
  result.forEach((ingr) => list.add(
        OwnedIngredient(name: ingr['name'], category: ingr['category'])));
  return list;
}

Future<List> getAllOwnedIngredientsList() async {
  List<Map> result = await db.query('owned');
  List<String> list = [];
  result.forEach((ingr) => list.add(ingr['name']));
  return list;
}

// Gets a list of all ingredients appearing in the database
Future<List> getAllIngredientsList() async {
  http.Response resp = await http.get('https://fft-group3.herokuapp.com/?req=list');
  if (resp.statusCode == 200) {
    return json.decode(resp.body);
  }
  throw Exception('Failed to load post');
}

// Gets recipes based on owned ingredients and decodes from json format
Future<List<Recipe>> fetchRecipes(List<String> ownedIngredients) async {
  String jsonOwned = json.encode(ownedIngredients);
  var param = {
    'req': 'recipe',
    'owned' : jsonOwned
  };
  Uri uri = Uri.parse('https://fft-group3.herokuapp.com/').replace(queryParameters: param);
  http.Response resp = await http.get(uri, headers: {HttpHeaders.contentTypeHeader: "application/json"} );

  if (resp.statusCode == 200) {
    List<Recipe> recipes = [];
    List jsonList = json.decode(resp.body);

    jsonList.forEach((obj) {
      recipes.add(Recipe.decodeJson(obj));
    });
    return recipes;
  }
  throw Exception('Failed to load post');
}

// Returns a list of elements from one column
List mapToList(List<Map> records, String key) {
  List list = [];
  records.forEach((mapping) {
    list.add(mapping[key].toString());
  });
  return list;
}


