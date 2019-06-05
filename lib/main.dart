import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'database.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

//Useful lists
final List<String> categories = <String>['Fruit', 'Vegetables', 'Dairy', 'Meat', 'Spices', 'Others'];
final List<String> menuChoices = <String>['Ingredients','My Recipes','Save the Planet','FAQ','About'];
final List<IconData> menuIcons = <IconData>[Icons.kitchen, Icons.favorite, Icons.lightbulb_outline, Icons.info];
final List<IconData> icons = <IconData>[FontAwesomeIcons.appleAlt,
  FontAwesomeIcons.carrot, FontAwesomeIcons.cheese, FontAwesomeIcons.drumstickBite, FontAwesomeIcons.pepperHot, FontAwesomeIcons.pizzaSlice];
List<Ingredient> allIngredients = [];

//main page
void main() => runApp(MyApp());

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
  static bool enableSearch = false;
  int _selectedIndex = 0;
  final List<String> _appBar = ['Ingredients', 'My Recipes', 'Reduce Food Waste', 'About'];

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
    SaveThePlanetPage(),
    Center(child: Text(
      'Wassup I\'m about page',
      style: TextStyle(fontSize: 30),
    ))
  ];



  @override
  Widget build(BuildContext context) {
    getAllIngredientsList().then((result) => allIngredients = result);
    return FutureBuilder(
      future: openAppDatabase(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          db = snapshot.data;
          return new Scaffold(
            appBar: AppBar(
              leading: Icon(menuIcons[_selectedIndex]),
              title: Text(_appBar[_selectedIndex], style: new TextStyle(fontSize: 25.0)),
              backgroundColor: Colors.teal,
              actions: <Widget>[
                _selectedIndex == 0 ? IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        enableSearch = !enableSearch;
                      });
                    }
                ) : Container(width: 0, height: 0),
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
            body: _selectedIndex == 0 ?
            new Container(
              child: new Column(
                children: <Widget>[
                  enableSearch ? new SearchBar() : new Container(width: 0, height: 0),
                  new Expanded(
                    child: new ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return new ExpandableListView(index: index);
                      },
                    ),
                  )
                ],
              ),
            )
                : _children[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
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
                    title: Text('Tips')
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.info),
                    title: Text('About')
                )
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.teal,
              onTap: _onItemTapped,
            ),
//            drawer: new Drawer(
//              child: new ListView.builder(
//                itemBuilder: (BuildContext context, int index) {
//                  return new Container(
//                    padding: const EdgeInsets.fromLTRB(0,10.0,0,10.0),
//                    child: new ListTile(
//                      leading: Icon(menuIcons[index]),
//                      title: new Text(
//                          menuChoices[index],style: TextStyle(fontSize: 18)
//                      ),
//                    ),
//                  );},
//                itemCount: menuChoices.length,
//              ),
//            ),
          );
        } else {
        return new Container(
              decoration: new BoxDecoration(color: Colors.white),
              child: new Center(
                child: new CircularProgressIndicator(backgroundColor: Colors.teal,
              strokeWidth: 5))
          );
        }
      }
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
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<OwnedIngredient>> key = new GlobalKey();

  //a row of autoComplete
  //TODO: decorate rows
  Widget storedRow(OwnedIngredient ownedIngredient) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          ownedIngredient.name,
          style: TextStyle(fontSize: 20.0),
        ),
        SizedBox(
          width: 40.0,
          height: 25,
        ),
        Text(
          ownedIngredient.category,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: getAllOwnedIngredients(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData? new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
            searchTextField = AutoCompleteTextField<OwnedIngredient>(
              key: key,
              clearOnSubmit: false,
              suggestions: snapshot.data,
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
                return item.name
                    .toLowerCase()
                    .contains(query.toLowerCase());
              },
              itemSorter: (a, b) {
                return a.name.compareTo(b.name);
              },
              itemSubmitted: (item) {
                setState(() {
                  searchTextField.clear();
                  searchTextField.textField.controller.text = item.name;
                });
              },
              itemBuilder: (context, item) {
                // ui for the autocompelete row
                return storedRow(item);
              },
            ),
          ],
        ) : new LinearProgressIndicator(backgroundColor: Colors.teal);
    });
  }
}



//Ingredient dropdown
class ExpandableListView extends StatefulWidget {
  final int index;
  List<OwnedIngredient> ingredientsList = [];

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
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              OwnedIngredient element = widget.ingredientsList[index];
              int daysLeft = element.getDifferenceInDays();
              Color expirationColour = (daysLeft < 0) ? Colors.teal :
              (daysLeft > 7) ? Colors.green :
              (daysLeft > 2) ? Colors.amber : Colors.red;
              return Slidable(
                direction: Axis.horizontal,
                actionPane: SlidableScrollActionPane(),
                actionExtentRatio: 0.2,
                child: Container(
                  child: new Row(
                    children: <Widget>[
                      new Expanded(child: new ListTile(
                      title: new Text(element.name),)),
                      new FlatButton(
                          onPressed: () {},
                          shape: StadiumBorder(),
                          color: expirationColour,
                          textColor:Colors.white,
                          child: Text(element.getExpirationText()
                          )),
                      new Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0))
                    ],
                  )
                ),
                actions: <Widget>[
                  IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () {
                      removeOwnedIngredient(widget.ingredientsList[index]
                          .name).whenComplete(() {
                        updateIngredientsList(categories[widget.index]);
                      });
                    },
                  ),
                ],
              );
            },
              itemCount: widget.ingredientsList.length,
            )
          )
        ],
      ),
    );
  }

  updateIngredientsList(String foodType) {
    getOwnedIngredientList(foodType).then((result) {
      setState(() {
        widget.ingredientsList = result;
        widget.ingredientsList.sort((a, b) =>
        (a.expires == null) ? 1 :
        (b.expires == null) ? -1 :
            a.expires.compareTo(b.expires));
      });
    });
  }

  Future<String> _asyncAddIngrDialog(BuildContext context) async {
    String newIngredient = '';
    DateTime expiryDate;
    bool isSwitched = false;

    callbackString(name) {
      setState(() {
        newIngredient = name;
      });
    }

    callbackDate(date) {
      print(date.toString());
      setState(() {
        expiryDate = date;
      });
    }

    callbackSwitch(value) {
      setState(() {
        isSwitched = value;
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
            child: AddIngredient(newIngredient, isSwitched, expiryDate,
                callbackString, callbackDate, callbackSwitch)
          ),

          actions: <Widget>[
            RaisedButton(
              color: Colors.teal,
              textColor: Colors.white,
              child: Text('ADD'),
              onPressed: () {
                Navigator.of(context).pop(newIngredient);
                addNewOwnedIngredient(newIngredient, isSwitched, expiryDate);
              },
            ),
          ],
        );
      },
    );
  }

  addNewOwnedIngredient(String newIngredient, bool isSwitched, DateTime expiryDate) {
    if (newIngredient.isEmpty) return;

    getAllOwnedIngredientsList().then((ownedList) {
      if (ownedList.contains(newIngredient)) return;
      if (!isSwitched) {
        addOwnedIngredient(categories[widget.index], newIngredient).whenComplete(() =>
            updateIngredientsList(categories[widget.index]));
      } else {
        addOwnedIngredientWithExpiry(categories[widget.index],
            newIngredient, expiryDate).whenComplete(() =>
            updateIngredientsList(categories[widget.index]));

      }
    });
  }
}

class AddIngredient extends StatefulWidget {

  String newIngredient;
  DateTime expiryDate;
  bool isSwitched;
  Function(String) callbackString;
  Function(DateTime) callbackDate;
  Function(bool) callbackSwitch;

  AddIngredient(this.newIngredient, this.isSwitched, this.expiryDate, this
      .callbackString, this.callbackDate, this.callbackSwitch);

  @override
  _AddIngredientState createState() => new _AddIngredientState();
}

class _AddIngredientState extends State<AddIngredient> {
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Ingredient>> key = new GlobalKey();

  Widget storedRow(Ingredient item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          item.name,
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          children: <Widget>[
            searchTextField = AutoCompleteTextField<Ingredient>(
              key: key,
              clearOnSubmit: false,
              suggestions: allIngredients,
              textChanged: (text) => widget.callbackString(text),
              style: TextStyle(color: Colors.black, fontSize: 16.0),
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.search, color: Colors.black),
                hintText: "Enter Ingredient",
                hintStyle: TextStyle(color: Colors.black),
              ),
              itemFilter: (item, query) {
                return item.name.toLowerCase()
                    .contains(query.toLowerCase());
              },
              itemSorter: (a, b) {
                return a.name.compareTo(b.name);
              },
              itemSubmitted: (item) {
                setState(() {
                  widget.callbackString(item.name);
                  widget.callbackDate(item.expires);
                  searchTextField.clear();
                  searchTextField.textField.controller.text = item.name;
                });
              },
              itemBuilder: (context, item) {
                // ui for the autocompelete row
                return storedRow(item);
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
                      widget.callbackSwitch(val);
                    });
                  },
                  activeTrackColor: Colors.teal,
                  activeColor: Colors.teal,
                ),
                Padding(padding: const EdgeInsets.all(10.0)),
                new RaisedButton(
                  child: Text('Add Expiry Date'),
                  onPressed: !widget.isSwitched ? null : ()
                  { showDatePicker(
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
                    ).then((date) => widget.callbackDate(date));
                  }
                )
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

class RecipeGen extends StatefulWidget {
  List<Recipe> recipesGenerated= [];

  @override
  _RecipeGenState createState() => new _RecipeGenState();
}
//Recipe generator page
class _RecipeGenState extends State<RecipeGen> {

  @override
  void initState() {
    super.initState();
    getAllOwnedIngredientsList().then((owned) {
      fetchRecipes(owned).then((recipes) {
        setState(() {
          widget.recipesGenerated = recipes;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int numRecipes = widget.recipesGenerated == null ? 0 : widget.recipesGenerated.length;
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
              image: new NetworkImage(widget.recipesGenerated[index].image),
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
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        title: Text(
          widget.recipesGenerated[index].name,
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
        Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  Recipe(
                      name: widget.recipesGenerated[index].name,
                      directions: widget.recipesGenerated[index].directions,
                      image: widget.recipesGenerated[index].image,
                      ingredientsUsed: widget.recipesGenerated[index].ingredientsUsed))
          );
        });
  }
}

//Recipe class - stores info regarding each recipe
class Recipe extends StatefulWidget  {
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
        ('$quantity ' + (unit == '' ? '' : (unit + ' of'))))
        + ' ' + ingredientName;
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

class OwnedIngredient {
  String name;
  String category;
  DateTime expires;

  OwnedIngredient({Key key, this.name, this.category, this.expires});

  Map<String, dynamic> toMap() {
    return {'name': name, 'category': category, 'expire': expires.toString()};
  }

  int getDifferenceInDays() {
    return (expires == null) ? -1 :
              expires.difference(DateTime.now()).inDays;
  }

  factory OwnedIngredient.fromMap(Map row) {
    DateTime date = ('null'.contains(row['expire'])) ?
                    null : DateTime.parse(row['expire']);
    return OwnedIngredient(
      name: row['name'],
      category: row['category'],
      expires: date,
    );
  }

  String getExpirationText() {
    return (expires == null) ? "No expiration date set" :
                  "Expires in " + getDifferenceInDays().toString() + " days";
  }
}

class SaveThePlanetPage extends StatelessWidget {

  List<String> tipTitle = <String>["Shop smartly and realistically",
  "Don’t over serve",
  "Save uneaten food",
  "Store food in the right places",
  "Freeze food if you can't finish them on time",
  "Revive past-it bread",
  "Avoid clutter in your fridge, pantry and freezer"
  ];

  List<String> tip
  = <String>["While shopping, make sure not to buy too much food "
      "so make a detailed shopping list before you go to the grocery store "
      "and stick to it.",
  "You can use small plates to help stick with portion sizes.",
  "Label them so you can keep track of how long they’ve been "
      "in your fridge/freezer, and use them in your routine.",
  "To last longer, keep apples, carrots, berries in the fridge."
      " Keep bananas, tomatoes, potatoes lemons and limes in a cool dry "
      "area.",
  "Some fruit and veg will "
      "lose their texture when frozen so you can freeze them pureed"
      " or stewed.",
  "If you still have bread past their best before date, put"
      " them in the oven for a few minutes to crisp them up again or make "
      "stale bread into breadcrumbs to use later on.",
  "Keep items neat and visible use the ‘First In First Out’ principle:"
      " after you buy new groceries, move the older products to the "
      "front so you consume them first."
  ];

  List<String> images = ["https://bit.ly/2MvayJb", "https://bit.ly/2XswN3n",
  "https://bit.ly/2Imuqsr", "https://bit.ly/2IjEAtT", "https://bit.ly/31aCEMZ",
  "https://bit.ly/2Wk6Ly1", "https://bit.ly/2Z6OMwz"];

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.8;
    double cardHeight = MediaQuery.of(context).size.height * 0.65;
    double cardOffset1 = cardWidth + 70.0;
    double cardOffset2 = cardHeight * 0.25;
    return new Swiper(
      layout: SwiperLayout.CUSTOM,
      customLayoutOption: new CustomLayoutOption(
          startIndex: -1,
          stateCount: 3
      ).addRotate([
        -45.0/180,
        0.0,
        45.0/180
      ]).addTranslate([
        new Offset(-cardOffset1, -cardOffset2),
        new Offset(0.0, 0.0),
        new Offset(cardOffset1, -cardOffset2)
      ]),
      itemWidth: cardWidth,
      itemHeight: cardHeight,
      itemBuilder: (context, index) {
        return new Container(
          decoration: new BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Color(0xfff5ded2)),
          child: new Column(
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(12, 25, 12, 12), child: Text(tipTitle[index], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0), textAlign: TextAlign.center,)),
                Padding(padding: const EdgeInsets.all(8.0), child:Image(image: NetworkImage(images[index]), fit: BoxFit.contain)),
                Padding(padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),child: Text(tip[index], style: TextStyle(fontSize: 22.0)))]
          ),
        );
      },
      itemCount: tip.length,
      control: new SwiperControl(color: Colors.teal),
    );
  }

}

