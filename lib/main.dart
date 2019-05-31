import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';


//example database
Database db;
final List<String> ingredients
= <String>['Fruit', 'Vegetables', 'Dairy', 'Meat', 'Spices'];
List<String> menuChoices = <String>['Ingredients','My Recipes','Save the Planet'
  ,'FAQ','About'];
List<IconData> menuIcons = <IconData>[Icons.kitchen, Icons.favorite,
  Icons.lightbulb_outline, Icons.help, Icons.info_outline];
final List<IconData> icons
= <IconData>[FontAwesomeIcons.appleAlt, FontAwesomeIcons.carrot, FontAwesomeIcons.cheese
  , FontAwesomeIcons.drumstickBite, FontAwesomeIcons.pepperHot];

//main page
void main() => runApp(new MaterialApp(home: new Home()));

// Open existing database
Future openAppDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, 'app.db');
  ByteData data = await rootBundle.load("./assets/database.db");
  List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(path).writeAsBytes(bytes);
  db = await openDatabase(path);
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    openAppDatabase();
    return Scaffold(
      appBar: AppBar(
        //leading: Icon(Icons.menu),
        title: Text('Ingredients', style: new TextStyle(fontSize: 25.0)),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.local_dining),
            onPressed: () {},
          ),
        ],
      ),
      drawer: new Drawer(
        child: new ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return new Container(
                  child: new ListTile(
                    leading: Icon(menuIcons[index]),
                    title: new Text(
                      menuChoices[index],
                    ),
                  ),
                );},
              itemCount: menuChoices.length,
            ),
        ),
      body: new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return new ExpandableListView(index: index);
        },
        itemCount: ingredients.length,
      ),
    );
  }
}

//Ingredient dropdown
class ExpandableListView extends StatefulWidget {
  final int index;

  const ExpandableListView({Key key, this.index}) : super(key: key);

  @override
  _ExpandableListViewState createState() => new _ExpandableListViewState();

}

class _ExpandableListViewState extends State<ExpandableListView> {
  bool expandFlag = false;
  List ingredientsList = [];

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.only(left: 10.0),
      padding: const EdgeInsets.all(15.0),
      child: new Column(
        children: <Widget>[
          new Container(
            child: new Row(
              children: <Widget>[
                new Icon(icons[widget.index]),
                Padding(padding: const EdgeInsets.all(10.0)),
                new Text(
                  ingredients[widget.index], style: TextStyle(fontSize: 20),
                ),
                new Row(
                  children: <Widget>[
                      new IconButton(icon: new Icon(
                      expandFlag ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 30.0,
                    ),
                        onPressed: () {
                          setState(() {
                            expandFlag = !expandFlag;
                          });
                        }),
                    new IconButton(icon: new Icon(Icons.add), onPressed: () => _asyncAddIngrDialog(context))],
                  ),
              ],
            ),
          ),
          new ExpandableContainer(
            expanded: expandFlag,
            index: ingredientsList.length,
            child: new ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return new Container(
                  child: new ListTile(
                    title: new Text(
                      ingredientsList[index],
                    ),
                  ),
                );},
              itemCount: ingredientsList.length,
            )
          )
        ],
      ),
    );
  }

  Future updateIngredientsList(String foodType) async {
    ingredientsList = await getFoodTypeList(foodType);
  }

  Future<String> _asyncAddIngrDialog(BuildContext context) async {
    String newIngredient = '';
    Future<DateTime> expiryDate;
    bool isSwitched = false;
    return showDialog<String>(
      context: context,
      barrierDismissible: true, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Ingredient'),
          content: new Container(
            height: 150.0,
            width: 400.0,
            child: new Column(
              children: <Widget>[
                new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(hintText: 'Enter Ingredient'),
                  onChanged: (value) {
                    newIngredient = value;
                  },
                ),
                Padding(padding: const EdgeInsets.all(10.0)),
                new Row(
                  children: <Widget>[
                    Switch(
                      value: isSwitched,
                      onChanged: (val) {
                        setState(() {
                          isSwitched = val;
                        });
                      },
                      activeTrackColor: Colors.teal,
                      activeColor: Colors.teal,
                    ),
                    Padding(padding: const EdgeInsets.all(10.0)),
                    new RaisedButton(onPressed: !isSwitched ? null : () { expiryDate = showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2019),
                      lastDate: DateTime(2030),
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData(primaryColor: Colors.teal, accentColor: Colors.teal),
                          child: child,
                        );
                      },
                    );}, child: Text('Add Expiry Date'))
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              color: Colors.teal,
              textColor: Colors.white,
              child: Text('ADD'),
              onPressed: () {
                Navigator.of(context).pop(newIngredient);
                if (newIngredient.isNotEmpty) {
                  addOwnedIngredient(db, ingredients[widget.index],
                      newIngredient);
                  updateIngredientsList(ingredients[widget.index]);
                }

              },
            ),
          ],
        );
      },
    );
  }

}

class ExpandableContainer extends StatelessWidget {
  final bool expanded;
  final double collapsedHeight;
  final int index;
  final double expandedHeight;
  final Widget child;

  ExpandableContainer({
    @required this.child,this.index,
    this.collapsedHeight = 0.0,
    this.expandedHeight = 300.0,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return new AnimatedContainer(
      duration: new Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: screenWidth,
      height: expanded ? (index * 55.0) : collapsedHeight,
      child: new Container(
        child: child,
      ),
    );
  }
}

//Return the corresponding specific ingredient list according to the foodType
Future<List> getFoodTypeList(String foodType) {
  return getOwnedIngredientList(db, foodType);
}

