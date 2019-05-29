import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final List<String> ingredients
= <String>['Fruit', 'Vegetables', 'Dairy', 'Meat', 'Spices'];
List<String> fruits = <String>['apple', 'orange', 'banana'];
List<String> vegs = <String>['broccoli', 'carrots', 'aubergines', 'asparagus'];
List<String> dairy = <String>['milk', 'almond milk'];
List<String> meat = <String>['lamb', 'chicken', 'beef'];
List<String> spices = <String>['chilli powder'];

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food for Thought',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Ingredients(),
    );
  }
}

class Ingredients extends StatefulWidget {
  @override
  IngredientsState createState() => IngredientsState();
}

class IngredientsState extends State<Ingredients> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //for onPressed change Icon to IconButton
        leading: Icon(Icons.menu),
        title: Text('Ingredients', style: new TextStyle(fontSize: 22.0)),
      ),
      body: _buildIngredients(),
    );
  }

  Widget _buildIngredients() {
    final List<String> ingredients
      = <String>['Fruit', 'Vegetables', 'Dairy', 'Meat', 'Spices'];
    final List<IconData> icons
      = <IconData>[FontAwesomeIcons.apple, FontAwesomeIcons.carrot, FontAwesomeIcons.cheese
                  , FontAwesomeIcons.drumstickBite, FontAwesomeIcons.pepperHot];
    return ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: ingredients.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Icon(icons[index]),
            title: Text('${ingredients[index]}',
                style: new TextStyle(fontSize: 20.0)),
            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.add),
                  Padding(padding: const EdgeInsets.all(10.0)),
                  IconButton(icon: Icon(Icons.arrow_drop_down),
                      onPressed: () => new HeaderIngredients(foodType: '${ingredients[index]}'))
                ]),
          );
        },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

class HeaderIngredients extends StatelessWidget {
  final foodType;

  const HeaderIngredients({Key key, this.foodType}) : super(key:key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExpandableIngredients(foodType: foodType),
    );
  }

}

class ExpandableIngredients extends StatelessWidget {
  final foodType;

  const ExpandableIngredients({Key key, this.foodType}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    List<String> lists = getFoodTypeList(foodType);
    final list = List.generate(lists.length, (i) => lists[i]);
    return new ListView.builder(
      itemBuilder: (context, i) => ExpansionTile(
        title: Text(foodType),
        children: list
            .map((val) => ListTile(
          title: Text(val),
        ))
            .toList(),
      ),
      itemCount: 1,
    );
  }

  List<String> getFoodTypeList(String foodType) {
    List<String> lists;
    switch(foodType) {
      case "Fruit":
        lists = fruits;
        break;
      case "Vegetables":
        lists = vegs;
        break;
      case "Dairy":
        lists = dairy;
        break;
      case "Meat":
        lists = meat;
        break;
      case "Spices":
        lists = spices;
        break;
    }
    return lists;
  }
}
