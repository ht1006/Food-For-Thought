import 'package:flutter/material.dart';

import 'database.dart';
import 'recipes.dart';

///Recipe generator page
class RecipeGen extends StatefulWidget {

  @override
  _RecipeGenState createState() => new _RecipeGenState();
}

class _RecipeGenState extends State<RecipeGen> {
  List<Recipe> recipesGenerated = [];
  bool _noRecipes = false;

  @override
  void initState() {
    super.initState();
    getAllOwnedIngredientsList().then((owned) {
      fetchRecipes(owned).then((recipes) {
        setState(() {
          recipes.sort((a, b) => a.missing.compareTo(b.missing));
          _noRecipes = recipes.isEmpty;
          recipesGenerated = recipes;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (_noRecipes) ?
          Center(
              child: Text(
                'No recipes found',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: MediaQuery.of(context).size.width * 0.065,
                  fontWeight: FontWeight.bold
                ), // TextStyle
              ) // Text
          ) // Center
          :
          Container(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: recipesGenerated.length,
              itemBuilder: (BuildContext context, int index) {
                return _makeRecipeCard(context,  recipesGenerated[index]);
              },
            ), // ListView
          ) // Container
    ); // Scaffold
  }
}


/// Liked recipe page
class LikedRecipeGen extends StatefulWidget {

  @override
  _LikedRecipeGenState createState() => new _LikedRecipeGenState();
}

class _LikedRecipeGenState extends State<LikedRecipeGen> {
  List<Recipe> recipesGenerated = [];
  bool _noRecipes = false;


  @override
  void initState() {
    super.initState();
    getLikedRecipes().then((likedList) {
      getAllLikedRecipesInfo(likedList).then((liked) {
        setState(() {
          _noRecipes = liked.isEmpty;
          recipesGenerated = liked;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal,
            title: Text(
                'Liked Recipes',
                style: new TextStyle(fontSize: MediaQuery.of(context).size.width * 0.063)
            ), // Text
          ), // AppBar
          body: (_noRecipes) ?
            Center(
                child: Text(
                  'No liked recipes',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: MediaQuery.of(context).size.width * 0.065,
                    fontWeight: FontWeight.bold
                  ), // TextStyle
                ) // Text
            ) // Center
            :
            Container(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: recipesGenerated.length,
                itemBuilder: (BuildContext context, int index) {
                  return _makeRecipeCard(context, recipesGenerated[index]);
                },
              ), // ListView
            ) // Container
      ); // Scaffold
  }
}




/// Funtions
Widget _makeRecipeCard(BuildContext context, Recipe recipe) {
  return Card(
    elevation: 8.0,
    semanticContainer: true,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
    child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new NetworkImage(recipe.image),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: _makeRecipeListTile(context, recipe)
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  );
}

// Fill in recipe card
Widget _makeRecipeListTile(BuildContext context, Recipe recipe) {
  List<String> plural = (recipe.missing > 1) ? ['s', 'are'] : ['', 'is'];
  return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      title: Text(
        recipe.name,
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 27.0,
            shadows: _getShadowTextStyle(Colors.black, 1.5)),
      ), // Text

      subtitle: Text(
        (recipe.missing > 0) ?
        '${recipe.missing} ingredient${plural[0]} ${plural[1]} missing' : '',
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
            shadows: _getShadowTextStyle(Colors.red, 1.0)
        ), // TextStyle
      ), // Text
      trailing:
      Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => recipe)
        );
      }
  ); // ListTile
}

// Returns shadow for text style
List<Shadow> _getShadowTextStyle(Color colour, double offset) {
  return [
    Shadow( // bottomLeft
        offset: Offset(-offset, -offset),
        color: colour
    ),
    Shadow( // bottomRight
        offset: Offset(offset, -offset),
        color: colour
    ),
    Shadow( // topRight
        offset: Offset(offset, offset),
        color: colour
    ),
    Shadow( // topLeft
        offset: Offset(-offset, offset),
        color: colour
    ),
  ];
}