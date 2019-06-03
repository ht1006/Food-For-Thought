import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';
import 'package:sticky_headers/sticky_headers.dart';

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
void main() => runApp(MyApp());

// Open existing database
//Future openAppDatabase() async {
//  var databasesPath = await getDatabasesPath();
//  var path = join(databasesPath, 'app.db');
//  ByteData data = await rootBundle.load("./assets/database.db");
//  List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//  await File(path).writeAsBytes(bytes);
//  db = await openDatabase(path);
//}

Future openAppDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, 'app.db');

  if (!(await databaseExists(path))) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    ByteData data = await rootBundle.load(join("assets", "database.db"));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  }

  db = await openDatabase(path);
}


class MyApp extends StatelessWidget {
  //static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  //Store different pages. Index 0 is Ingredients page, 1 is My Recipes, 3 is FAQ
  final List<Widget> _children = [
    new Container(child: new Column(children: <Widget>[
      new Container(child: new Column(
        children: <Widget>[
          Padding(padding: const EdgeInsets.fromLTRB(8,15.0,8,0),
            child: TextField(
              onChanged: (searchIngredient) {
                //TODO： deal with the input ingredient
              },
              decoration: InputDecoration(
                  labelText: "Search For Ingredients",
                  prefixIcon: Icon(Icons.search),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
              ),))
        ],
      )),
      new Expanded(child: new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return new ExpandableListView(index: index);
        },
        itemCount: ingredients.length,
      ),)
    ],),),
    Center(child: Text(
      'Wassup I\'m recipe page',
      style: TextStyle(fontSize: 30),
    )),
    Center(child: Text(
      'Wassup I\'m FAQ page',
      style: TextStyle(fontSize: 30),
    )),

  ];

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeGen()),
              );
            },
          ),
        ],
      ),
      body:_children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.kitchen),
            title: new Text('Ingredients'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.favorite),
            title: new Text('My Recipes'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.help),
              title: Text('FAQ')
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
      drawer: new Drawer(
        child: new ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return new Container(
                  padding: const EdgeInsets.fromLTRB(0,10.0,0,10.0),
                  child: new ListTile(
                    leading: Icon(menuIcons[index]),
                    title: new Text(
                      menuChoices[index],style: TextStyle(fontSize: 18)
                    ),
                  ),
                );},
              itemCount: menuChoices.length,
            ),
        ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                  ingredients[widget.index], style: TextStyle(fontSize: 19),
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
              return new Container(child: new Row(children: <Widget>[
                new Expanded(child: new ListTile(
                title: new Text(ingredientsList[index]),)),
                new IconButton(icon: new Icon(Icons.delete), onPressed: () =>
                    deleteIngredient(context, index))],))
              ;},
              itemCount: ingredientsList.length,
            )
//Maybe useful for sticky header
//          ExpandableContainer(
//            expanded: expandFlag,
//            index: ingredientsList.length,
//            child: new ListView.builder(
//                itemBuilder: (BuildContext context, int index) {
//                  return new StickyHeader(
//                  header: new Text(ingredientsList[index],),
//                  content: new ListTile(
//                    title: new Text(ingredientsList[index],
//                    ),
//                  ),);})
//          )
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

    callback(value) {
      setState(() {
        newIngredient = value;
      });
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: true, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Ingredient'),
          content: new Container(
            height: 150.0,
            width: 400.0,
            child: AddIngredient(newIngredient, isSwitched,
                expiryDate, callback)
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

  //TODO: delete the ingredient
  deleteIngredient(BuildContext context, int index) {
    print("Hey yo wassup I wanna delete " + ingredientsList[index]);
  }

}

class AddIngredient extends StatefulWidget {

  String newIngredient;
  Future<DateTime> expiryDate;
  bool isSwitched;
  Function(String) callback;

  AddIngredient(this.newIngredient, this.isSwitched, this.expiryDate, this.callback);

  @override
  _AddIngredientState createState() => new _AddIngredientState();
}

class _AddIngredientState extends State<AddIngredient> {

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return new Column(
      children: <Widget>[
        new TextField(
          autofocus: true,
          decoration: new InputDecoration(hintText: 'Enter Ingredient'),
          onChanged: (value) {
            widget.callback(value);
          },
        ),
        Padding(padding: const EdgeInsets.all(10.0)),
        new Row(
          children: <Widget>[
            Switch(
              value: widget.isSwitched,
              onChanged: (val) {
                setState(() {
                  widget.isSwitched = val;
                });
              },
              activeTrackColor: Colors.teal,
              activeColor: Colors.teal,
            ),
            Padding(padding: const EdgeInsets.all(10.0)),
            new RaisedButton(onPressed: !widget.isSwitched ? null : () { widget.expiryDate = showDatePicker(
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

//Recipe generator page
class RecipeGen extends StatelessWidget {
  List<Recipe> example
    = <Recipe>[new Recipe(name: 'Shakshouka',
                          ingredientsUsed: null,
                          directions: 'do this do that'),
               new Recipe(name: 'Fattoush',
                          ingredientsUsed: null,
                          directions: 'hi there, some instructions here'),
               new Recipe(name: 'Fried Chicken',
                          ingredientsUsed: null,
                          directions: 'fry the chicken')];
  List<String> exampleImages
    = <String>[
      "https://bit.ly/2W5WzsF", "https://bit.ly/312xmCW", "https://bit.ly/2W9jXW6"
    ];

  @override
  Widget build(BuildContext context) {
    List<Recipe> recipesGenerated = _fetch_recipes();
    int numRecipes = recipesGenerated == null ? 0 : recipesGenerated.length;
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
            //itemCount: numRecipes instead of example
            itemCount: example.length,
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
              //use image field from Recipe class instead
              image: new NetworkImage(exampleImages[index]),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
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
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        title: Text(
          //below, it would be recipesGenerated[index].name instead of example
          example[index].name,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 27.0,
              shadows: [
                Shadow( // bottomLeft
                    offset: Offset(-1.5, -1.5),
                    color: Colors.black
                ),
                Shadow( // bottomRight
                    offset: Offset(1.5, -1.5),
                    color: Colors.black
                ),
                Shadow( // topRight
                    offset: Offset(1.5, 1.5),
                    color: Colors.black
                ),
                Shadow( // topLeft
                    offset: Offset(-1.5, 1.5),
                    color: Colors.black
                ),
              ]),
        ),
        trailing:
        Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0));
  }
}

//Recipe class - stores info regarding each recipe
class Recipe extends StatelessWidget {
  final String name;
  // insert picture declaration here
  final List<IngredientUsed> ingredientsUsed;
  final String directions;

  const Recipe({Key key, this.name, this.directions, this.ingredientsUsed}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(name, style: new TextStyle(fontSize: 25.0)),
          backgroundColor: Colors.teal
      ),
      body: Container(

      )
    );
  }

}

class IngredientUsed extends StatelessWidget {
  final String ingredientName;
  final int quantity;
  final String unit;

  const IngredientUsed({Key key, this.ingredientName, this.quantity, this.unit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('$quantity' + ' ' + unit + ' ' + ingredientName);
  }

}

List<Recipe> _fetch_recipes() {
  return null;
}

