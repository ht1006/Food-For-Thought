import 'dart:core';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';


// Add an ingredient to the 'owned' table
Future addOwnedIngredient(Database db, String category, String ingredient) async {
  await db.insert('owned',
      OwnedIngredient(ingredient: ingredient, category: category).toMap());
}

// Removes an ingredient to the 'owned' table
Future removeOwnedIngredient(Database db, String ingredient) async {
  await db.delete('owned', where: '"ingredient" = ?', whereArgs: [ingredient]);
}

// Retrieves list of owned ingredients from the given category
Future<List> getOwnedIngredientList(Database db, String category) async {
  List<Map> result = await db.query('owned', where: '"category" = ?',
      whereArgs: [category], distinct: true);
  return mapToList(result, 'ingredient');
}

// Retrieves list of owned ingredients from the given category
Future<List> getAllOwnedIngredients(Database db) async {
  List<Map> result = await db.query('owned');
  return mapToList(result, 'ingredient');
}

// Gets a list of all ingredients appearing in the database
Future<List<String>> getAllIngredientsList() async {
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
    List<Map> jsonList = json.decode(resp.body);
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

class OwnedIngredient {
  final String ingredient;
  final String category;

  OwnedIngredient({this.ingredient, this.category});

  Map<String, dynamic> toMap() {
    return {'ingredient': ingredient, 'category': category,};
  }
}
