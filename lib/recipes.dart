import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'database.dart';

//Recipe class - stores info regarding each recipe
class Recipe extends StatefulWidget  {
  final int id;
  final String name;
  final String directions;
  final String image;
  final List<IngredientUsed> ingredientsUsed;
  int missing;
  bool liked;

  Recipe({Key key, this.id, this.name, this.directions, this.image, this
      .ingredientsUsed, this.missing, this.liked = false}) : super(key: key);

  factory Recipe.decodeJson(Map<String, dynamic> json) {
    List<IngredientUsed> ingredients = [];
    List<dynamic> jsonIngredients = json['ingredients'];
    jsonIngredients.forEach((i) {
      ingredients.add(IngredientUsed.decodeJson(i));
    });
    return Recipe(
      id: json['id'],
      name: json['name'],
      directions: json['directions'],
      ingredientsUsed: ingredients,
      image: json['image'],
      missing: json['missing'],
    );
  }

  @override
  _RecipeState createState() => new _RecipeState();
}

class _RecipeState extends State<Recipe> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.name, style: new TextStyle(fontSize: 25.0)),
            actions: <Widget>[
              IconButton(
                  icon: widget.liked ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
                  color: widget.liked ? Colors.red : null,
                  onPressed: () {
                    if (widget.liked) removeRecipeFromLiked(widget.id);
                    else addRecipeToLiked(this.widget);
                    setState(() {
                      widget.liked = !widget.liked;
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
    int count = 0;
    var splitDir = directions.split("\\n").map((i) {
      count++;
      return Container(
          child: new Column(children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(12, 8, 12, 8),child:
             Text(count.toString() + ". " + i, style: TextStyle(fontSize: 20.0))),
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
            child: Padding(padding: EdgeInsets.fromLTRB(12, 3, 12, 3),child:Text(formatIngredientText(text),
                style: TextStyle(fontSize: 20.0)))
        )
    );
  }

  String formatIngredientText(String text) {
    return '\u2022 ' + text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

}