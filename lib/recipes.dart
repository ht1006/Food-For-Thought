import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'database.dart';

//Recipe generator page
class RecipeGen extends StatefulWidget {

  @override
  _RecipeGenState createState() => new _RecipeGenState();
}

class _RecipeGenState extends State<RecipeGen> {
  List<Recipe> recipesGenerated = [];

  @override
  void initState() {
    super.initState();
    getAllOwnedIngredientsList().then((owned) {
      fetchRecipes(owned).then((recipes) {
        setState(() {
          recipes.sort((a, b) => a.missing.compareTo(b.missing));
          recipesGenerated = recipes;
        });
      });
    });
  }

  //TODO: If no result, display 'No result' text
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                "Recipe Suggestions", style: new TextStyle(fontSize: 25.0)),
            backgroundColor: Colors.teal
        ),
        body: Container(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: recipesGenerated.length,
            itemBuilder: (BuildContext context, int index) {
              return _makeRecipeCard(index);
            },
          ),
        )
    );
  }

  Widget _makeRecipeCard(int index) {
    return Card(
      elevation: 8.0,
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: new NetworkImage(recipesGenerated[index].image),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          child: _makeRecipeListTile(index)
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget _makeRecipeListTile(int index) {
    Recipe recipe = recipesGenerated[index];
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
        //TODO: Maybe to icons to indicate missing ingredient or sth
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
              MaterialPageRoute(builder: (context) =>
                  Recipe(
                      name: recipesGenerated[index].name,
                      directions: recipesGenerated[index].directions,
                      image: recipesGenerated[index].image,
                      ingredientsUsed: recipesGenerated[index].ingredientsUsed))
          );
        }
    ); // ListTile
  }

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
}

//Recipe class - stores info regarding each recipe
class Recipe extends StatefulWidget  {
  final String name;
  final String directions;
  final String image;
  final List<IngredientUsed> ingredientsUsed;
  int missing;

  Recipe({Key key, this.name, this.directions, this.image, this
      .ingredientsUsed, this.missing}) : super(key: key);

  factory Recipe.decodeJson(Map<String, dynamic> json) {
    List<IngredientUsed> ingredients = [];
    List<dynamic> jsonIngredients = json['ingredients'];
    jsonIngredients.forEach((i) {
      ingredients.add(IngredientUsed.decodeJson(i));
    });
    return Recipe(
      name: json['name'],
      directions: json['directions'],
      ingredientsUsed: ingredients,
      image: json['image'],
      missing: int.parse(json['missing']),
    );
  }

  @override
  _RecipeState createState() => new _RecipeState();

}

class _RecipeState extends State<Recipe> {
  //TODO: store favourite recipe in database
  bool likedRecipe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.name, style: new TextStyle(fontSize: 25.0)),
            actions: <Widget>[
              IconButton(
                  icon: likedRecipe ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
                  color: likedRecipe ? Colors.red : null,
                  onPressed: () {
                    setState(() {
                      likedRecipe = !likedRecipe;
                    });
                  }
              )
            ],
            backgroundColor: Colors.teal
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image(image: NetworkImage(widget.image)),
                  Padding(padding: const EdgeInsets.all(8.0)),
                  Text("Ingredients", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0, color: Colors.teal)),
                  Padding(padding: const EdgeInsets.all(8.0)),
                  Column(children: _displayIngredientsUsed(widget.ingredientsUsed, context)),
                  Padding(padding: const EdgeInsets.all(8.0)),
                  Text("Directions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0, color: Colors.teal)),
                  Padding(padding: const EdgeInsets.all(8.0)),
                  _displayDirections(widget.directions, context)
                ],),
            )
        )
    );
  }

  _displayIngredientsUsed(List<IngredientUsed> ingredientsUsed, BuildContext context) {
    List<Widget> columnContent = [];
    for (IngredientUsed ingr in ingredientsUsed) {
      columnContent.add(ingr.build(context));
    }
    return columnContent;
  }

  _displayDirections(String directions, BuildContext context) {
    var splitDir = directions.split("\\n").map((i) {
      return Container(
          child: new Column(children: <Widget>[
            Text(i, style: TextStyle(fontSize: 20.0)),
            Padding(padding: const EdgeInsets.all(5.0))
          ]));
    }).toList();
    return Column(children: splitDir, crossAxisAlignment: CrossAxisAlignment.start);
  }
}

// Class representing the ingredient used in a recipe
class IngredientUsed extends StatelessWidget {
  final String ingredientName;
  final int quantity;
  final String unit;

  const IngredientUsed({Key key, this.ingredientName, this.quantity, this.unit}) : super(key: key);

  factory IngredientUsed.decodeJson(Map<String, dynamic> json) {
    return IngredientUsed(
      ingredientName: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
    );
  }

  @override
  Widget build(BuildContext context) {
    String text = (quantity == 0 ? unit :
    ('$quantity' + (unit == '' ? '' : (' $unit of'))))
        + ' $ingredientName' + ((quantity > 1 && unit == '') ? 's' : '');
    return Align(
        alignment: Alignment.centerLeft,
        child: Container(
            child: Text(formatIngredientText(text),
                style: TextStyle(fontSize: 20.0))
        )
    );
  }

  String formatIngredientText(String text) {
    return '\u2022 ' + text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

}