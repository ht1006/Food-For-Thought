import 'package:flutter/material.dart';
import 'database.dart';
import 'recipes.dart';

List<Recipe> likedRecipes
= <Recipe>[
  new Recipe(name: 'Fried Chicken', directions: 'fry the chicken',
      image: "https://bit.ly/31ib8xa",
      ingredientsUsed: <IngredientUsed>[new IngredientUsed(ingredientName: 'chicken', quantity: 1, unit: 'kg')])
];

class LikedRecipes extends StatefulWidget {

  @override
  _LikedRecipeState createState() => new _LikedRecipeState();
}

class _LikedRecipeState extends State<LikedRecipes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("My Recipes", style: new TextStyle(fontSize: 25.0)),
            backgroundColor: Colors.teal
        ),
        body: Center(child: Text("Liked Recipe Page!", style: new TextStyle(fontSize: 25.0)))
    );
  }

}