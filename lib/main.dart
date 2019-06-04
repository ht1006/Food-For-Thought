import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

//example database
Database db;
final List<String> categories
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

Future openAppDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, 'app.db');

  if (!(await databaseExists(path))) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
  }

  db = await openDatabase(path, version: 1, onCreate: (db, version) {
    return db.execute('CREATE TABLE owned(ingredient TEXT NOT NULL, '
        'category TEXT NOT NULL, expire DATE)');
  });
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
  final List<String> _appBar = ['Ingredients', 'My Recipes', 'Save the Planet'];

  //Store different pages. Index 0 is Ingredients page, 1 is My Recipes, 3 is FAQ
  final List<Widget> _children = [
    new Container(child: new Column(children: <Widget>[
      new SearchBar(),
      new Expanded(child: new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return new ExpandableListView(index: index);
        },
        itemCount: categories.length,
      ),)
    ],),),
    Center(child: Text(
      'Wassup I\'m recipe page',
      style: TextStyle(fontSize: 30),
    )),
    Center(child: Text(
      'Wassup I\'m a Save the Planet page',
      style: TextStyle(fontSize: 30),
    )),

  ];

  @override
  Widget build(BuildContext context) {
    openAppDatabase();
    return Scaffold(
      appBar: AppBar(
        //leading: Icon(Icons.menu),
        title: Text(_appBar[_selectedIndex], style: new TextStyle(fontSize: 25.0)),
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
              icon: Icon(Icons.lightbulb_outline),
              title: Text('Save the Planet')
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

//search bar in the home page
class SearchBar extends StatefulWidget {
  SearchBar() : super();
  List<OwnedIngredient> stored;
  @override
  _SearchBarState createState() => _SearchBarState();

}

class _SearchBarState extends State<SearchBar> {
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<OwnedIngredient>> key = new GlobalKey();

  @override
  void initState() {
    super.initState();
    getOwnedIngredientsPair();
  }

  void getOwnedIngredientsPair() async {
    List<OwnedIngredient> list = [];
    print("In getOwnedIngredientsPair");
    categories.forEach((cat) async {
      List ingredients = await getOwnedIngredientList(db, cat);
      ingredients.forEach((ingr) {
        list.add(OwnedIngredient(ingredient: ingr, category: cat));
      });
    });
    print("list" + list.length.toString());
    widget.stored = list;
//    print("In owned");
//    List ingredients = await getAllOwnedIngredients(db);
//    print("MylengthHIIIII: " + ingredients.length.toString());
//    List categories = await getAllOwnedIngredientsCategories(db);
//    print("Mylengt2hHIIIII: " + categories.length.toString());
//
//    List res;
//    for (var i = 0; i < ingredients.length; i++) {
//      res.add(OwnedIngredient(ingredient: ingredients[i], category: categories[i]));
//    }
//    print(res);
//    widget.stored = res;
  }

  //a row of autoComplete
  Widget storedRow(OwnedIngredient OwnedIngredient) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          OwnedIngredient.ingredient,
          style: TextStyle(fontSize: 20.0),
        ),
        SizedBox(
          width: 40.0,
        ),
        Text(
          OwnedIngredient.category,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    getOwnedIngredientsPair();
    print(widget.stored);

    return new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
          searchTextField = AutoCompleteTextField<OwnedIngredient>(
          key: key,
          clearOnSubmit: false,
          suggestions: widget.stored,
          style: TextStyle(color: Colors.black, fontSize: 16.0),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.teal),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              contentPadding: EdgeInsets.all(20.0),
              hintText: "Search For Ingredient",
              hintStyle: TextStyle(color: Colors.black),
            ),
          itemFilter: (item, query) {
            return item.ingredient
                .toLowerCase()
                .startsWith(query.toLowerCase());
          },
          itemSorter: (a, b) {
            return a.ingredient.compareTo(b.ingredient);
          },
          itemSubmitted: (item) {
            setState(() {
              searchTextField.textField.controller.text = item.ingredient;
            });
          },
          itemBuilder: (context, item) {
            // ui for the autocompelete row
            return storedRow(item);
          },
        ),
      ],
    );
  }
}



//Ingredient dropdown
class ExpandableListView extends StatefulWidget {
  final int index;
  List ingredientsList = [];

  ExpandableListView({Key key, this.index}) : super(key: key);

  @override
  _ExpandableListViewState createState() => new _ExpandableListViewState();

}

class _ExpandableListViewState extends State<ExpandableListView> {
  bool expandFlag = false;

  @override
  Widget build(BuildContext context) {
    updateIngredientsList(categories[widget.index]);
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
                  categories[widget.index], style: TextStyle(fontSize: 19),
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
            index: widget.ingredientsList.length,
            child: new ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return new Container(
                  child: new Row(
                    children: <Widget>[
                      new Expanded(child: new ListTile(
                      title: new Text(widget.ingredientsList[index]),)),
                      new FlatButton(
                          onPressed: () {},
                          shape: StadiumBorder(),
                          color: Colors.amber,
                          textColor:Colors.white,
                          child: Text("Expires in  days")),
                      new IconButton(icon: new Icon(Icons.delete), onPressed: () {
                        removeOwnedIngredient(db, widget.ingredientsList[index]);
                        updateIngredientsList(categories[widget.index]);
                      })
                    ],
                  )
              );
            },
              itemCount: widget.ingredientsList.length,
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
    List newIngredients = await getFoodTypeList(foodType);
    setState(() {
      widget.ingredientsList = newIngredients;
    });
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
                if (newIngredient.isNotEmpty
                    && !widget.ingredientsList.contains(newIngredient)) {
                  addOwnedIngredient(db, categories[widget.index],
                      newIngredient);
                  updateIngredientsList(categories[widget.index]);
                }

              },
            ),
          ],
        );
      },
    );
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
  List<Recipe> recipesGenerated;

  Future getRecipes() async {
    List<String> ownedIngredients = await getAllOwnedIngredients(db);
    recipesGenerated = await fetchRecipes(ownedIngredients);
  }

  @override
  Widget build(BuildContext context) {
    getRecipes();
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
            itemCount: numRecipes,
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
              image: new NetworkImage(recipesGenerated[index].image),
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
          recipesGenerated[index].name,
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
  final String directions;
  final String image;
  final List<IngredientUsed> ingredientsUsed;

  const Recipe({Key key, this.name, this.directions, this.image, this.ingredientsUsed}) : super(key: key);

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
    );
  }

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

  factory IngredientUsed.decodeJson(Map<String, dynamic> json) {
    return IngredientUsed(
      ingredientName: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text('$quantity' + ' ' + unit + ' ' + ingredientName);
  }

}

class OwnedIngredient {
  final String ingredient;
  final String category;

  OwnedIngredient({Key key, this.ingredient, this.category});

  Map<String, dynamic> toMap() {
    return {'ingredient': ingredient, 'category': category,};
  }
}



