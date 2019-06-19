import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'ingredients.dart';
import 'recipes.dart';
import 'utils.dart';

Database db;

/// LOCAL DATABASE FUNCTIONS (Owned ingredients)

// Open local database, create one if it does not exist
Future<Database> openAppDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, 'app.db');

  if (!(await databaseExists(path))) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
  }

  return await openDatabase(path, version: 1, onCreate: (db, version) async {
    await db.execute('CREATE TABLE owned(name TEXT PRIMARY KEY, category TEXT NOT NULL, expire TEXT)');
    await db.execute('CREATE TABLE liked(id INTEGER PRIMARY KEY)');
  });
}

// Add an ingredient to the 'owned' table
Future addOwnedIngredient(String category, String ingredient) async {
  await db.insert('owned',
      OwnedIngredient(name: ingredient, category: category).toMap());
}

// Add an ingredient to the 'owned' table with an expiry date
Future addOwnedIngredientWithExpiry(String category, String ingredient,
    DateTime expires) async {
  await db.insert('owned',
      OwnedIngredient(name: ingredient, category: category, expires: expires)
          .toMap());
}

// Removes an ingredient to the 'owned' table
Future removeOwnedIngredient(String ingredient) async {
  await db.delete('owned', where: '"name" = ?', whereArgs: [ingredient]);
  cancelNotification(ingredient);
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

// Retrieves list of all owned ingredients, for search bar
Future<List<OwnedIngredient>> getAllOwnedIngredients() async {
  List<Map> result = await db.query('owned');
  List<OwnedIngredient> list = [];
  result.forEach((ingr) => list.add(
        OwnedIngredient(name: ingr['name'], category: ingr['category'])));
  return list;
}

// Gets all the ingredients owned (name only)
Future<List<String>> getAllOwnedIngredientsList() async {
  List<Map> result = await db.query('owned');
  List<String> list = [];
  result.forEach((ingr) => list.add(ingr['name']));
  return list;
}

// Add a recipe to the 'liked' table
Future addRecipeToLiked(Recipe recipe) async {
  db.insert('liked', {'id': recipe.id});
}

// Remove a recipe from the liked table
Future removeRecipeFromLiked(int id) async {
  db.delete('liked', where: '"id" = ?', whereArgs: [id]);
}

// Retrieve all the liked recipes
Future<List<int>> getLikedRecipes() async {
  List<Map> results = await db.query('liked');
  List<int> likedList = [];
  results.forEach((recipe) {
    likedList.add(recipe['id']);
  });
  return likedList;
}

/// REMOTE DATABASE

// Gets a list of all ingredients appearing in the remote database
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

// Gets recipes based on owned ingredients and decodes from json format
Future<List<Recipe>> fetchRecipes(List<String> ownedIngredients) async {
  var param = {
    'req': 'recipe',
    'owned' : json.encode(ownedIngredients)
  };
  List jsonList = await _getRequest(param);

  List<int> likedList = await getLikedRecipes();
  List<Recipe> recipes = [];
  jsonList.forEach((obj) {
    Recipe recipe = Recipe.decodeJson(obj);
    recipes.add(_setLiked(recipe, likedList));
  });
  return recipes;
}

// Set a recipe to liked if it is in database table 'liked'
Recipe _setLiked(Recipe recipe, List<int> likedList) {
  for (int i = 0; i < likedList.length; i++) {
    if (recipe.id == likedList[i]) {
      recipe.liked = true;
      break;
    }
  }
  return recipe;
}

// Get the info of all liked recipes
Future<List<Recipe>> getAllLikedRecipesInfo(List<int> likedList) async {
  var param = {
    'req': 'liked',
    'ids' : json.encode(likedList)
  };
  List jsonList = await _getRequest(param);
  List<Recipe> likedRecipes = [];
  jsonList.forEach((obj) {
    Recipe recipe = Recipe.decodeJson(obj);
    recipe.liked = true;
    likedRecipes.add(recipe);
  });
  return likedRecipes;
}

// Send an http get request to the database
Future<List> _getRequest(Map param) async {
  Uri uri = Uri.parse('https://fft-group3.herokuapp.com/').replace(queryParameters: param);
  http.Response resp = await http.get(uri, headers: {HttpHeaders.contentTypeHeader: "application/json"} );
  if (resp.statusCode == 200) {
    return json.decode(resp.body);
  }
  throw Exception('Failed to load post');
}


void uploadNewRecipe(Recipe recipe) {
  var param = {
    'req': 'new',
    'recipe' : json.encode(recipe.encodeJson())
  };
  _postRequest(param);
}

// Send an http post request to the database
Future _postRequest(Map param) async {
  Uri uri = Uri.parse('https://fft-group3.herokuapp.com/').replace(queryParameters: param);
  http.Response resp = await http.post(uri, headers: {HttpHeaders.contentTypeHeader: "application/json"} );
  if (resp.statusCode != 200) {
    throw Exception('Failed to upload recipe');
  }
}