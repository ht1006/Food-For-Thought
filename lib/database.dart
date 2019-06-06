import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'ingredients.dart';
import 'recipes.dart';

Database db;

// Open local database
Future<Database> openAppDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, 'app.db');

  if (!(await databaseExists(path))) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
  }

  return await openDatabase(path, version: 1, onCreate: (db, version) {
    return db.execute('CREATE TABLE owned(name TEXT NOT NULL, '
        'category TEXT NOT NULL, expire TEXT)');
  });
}

// Add an ingredient to the 'owned' table
Future addOwnedIngredient(String category, String ingredient) async {
  await db.insert('owned',
      OwnedIngredient(name: ingredient, category: category).toMap());
}

Future addOwnedIngredientWithExpiry(String category, String ingredient,
    DateTime expires) async {
  await db.insert('owned',
      OwnedIngredient(name: ingredient, category: category, expires: expires)
          .toMap());
}

// Removes an ingredient to the 'owned' table
Future removeOwnedIngredient(String ingredient) async {
  await db.delete('owned', where: '"name" = ?', whereArgs: [ingredient]);
}

// Retrieves list of owned ingredients from the given category
Future<List<OwnedIngredient>> getOwnedIngredientList(String category) async {
  List<Map> result = await db.query('owned', where: '"category" = ?',
      whereArgs: [category], distinct: true);
  List<OwnedIngredient> owned = [];
  result.forEach((ingredient) {
    owned.add(OwnedIngredient.fromMap(ingredient));
  });
  return owned;
}

// Retrieves list of all owned ingredients
Future<List<OwnedIngredient>> getAllOwnedIngredients() async {
  List<Map> result = await db.query('owned');
  List<OwnedIngredient> list = [];
  result.forEach((ingr) => list.add(
        OwnedIngredient(name: ingr['name'], category: ingr['category'])));
  return list;
}


// Gets a list of all ingredients appearing in the database
Future<List<Ingredient>> getAllIngredientsList() async {
  http.Response resp = await http.get('https://fft-group3.herokuapp.com/?req=list');
  if (resp.statusCode == 200) {
    List jsonObj = json.decode(resp.body);
    List<Ingredient> allIngredients = [];
    jsonObj.forEach((obj) {
      allIngredients.add(Ingredient.decodeJson(obj));
    });
    return allIngredients;
  }
  throw Exception('Failed to load post');
}

// Gets all the ingredients owned (name only, for recipes)
Future<List<String>> getAllOwnedIngredientsList() async {
  List<Map> result = await db.query('owned');
  List<String> list = [];
  result.forEach((ingr) => list.add(ingr['name']));
  return list;
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

// Return current date with hour, minute, second set to 0
DateTime getNormalisedCurrentDate() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}



