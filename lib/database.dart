import 'dart:core';
import 'package:sqflite/sqflite.dart';

class OwnedIngredient {
  final String name;
  final String category;

  OwnedIngredient(this.name, this.category);

  Map<String, dynamic> toMap() {
    return {'ingredient': name, 'category': category,};
  }
}

// Add an ingredient to the 'owned' table
Future addOwnedIngredient(Database db, String category, String ingredient) async {
  await db.insert('owned', OwnedIngredient(ingredient, category).toMap());
}

// Removes an ingredient to the 'owned' table
Future removeOwnedIngredient(Database db, String ingredient) async {
  await db.delete('owned', where: '"ingredient" = ?', whereArgs: [ingredient]);
}

// Retrieves list of owned ingredients from the given category
Future<List> getOwnedIngredientList(Database db, String category) async {
  List<Map> result = await db.query('owned', where: '"category" = ?',
      whereArgs: [category]);
  return mapToList(result, 'ingredient');
}

// Given list of ingredients, returns list of corresponding IDs
Future<List<int>> getIngrIDs(Database db, List<String> ingredients) async {
  List<int> ids = new List(ingredients.length);
  List<Map> result = await db.query('ingredients', columns: ['id'],
      where: '"ingredient" = ?', whereArgs: [ingredients]);
  result.forEach((ingr) async {
    ids.add(ingr['id']);
  });
  return ids;
}

// Given list of ingredient IDs, finds recipes IDs witch matching ingredients
Future<List> getMatchingRecipes(Database db, List<int> ingredients) async {
  List<Map> result = await db.query('recipes', distinct: true,
      columns: ['dish_id'], where: '"ingr_id" = ?', whereArgs: ingredients);

  return mapToList(result, 'dish_id');
}


// Returns a list of elements from one column
List mapToList(List<Map> records, String key) {
  List list = [];
  records.forEach((mapping) {
    list.add(mapping[key].toString());
  });
  return list;
}

// Get ID of a dish
Future<int> getDishID(Database db, String dish) async {
  return (await db.query('dishes', columns: ['id'],
              where: '"ingredient" = ?', whereArgs: [dish]))[0]['id'];
}

// Gets ingredients of a recipe and their quantity/units
Future<List> getIngredientsList(Database db, int dish_id) async {
  List<Map> result = await db.query('recipes r JOIN ingredients i ON (r'
      '.ingr_id = i.id)', columns: ['id', 'quantity', 'unit'], where: '"dish_id'
      '" = ?', whereArgs: [dish_id.toString()]);
  return result;
}

// Gets info needed to display recipe
void displayRecipes(Database db, List<int> recipes) async {
  List<Map> result = await db.query('dishes', distinct: true);
}