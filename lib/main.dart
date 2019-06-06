import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'database.dart';
import 'recipes.dart';
import 'ingredients.dart';
import 'tipsPage.dart';


//Useful lists
final List<String> menuChoices = <String>['Ingredients','My Recipes','Save the Planet','FAQ','About'];
final List<IconData> menuIcons = <IconData>[Icons.kitchen, Icons.favorite, Icons.lightbulb_outline, Icons.info];
final List<String> categories = <String>['Fruits', 'Vegetables', 'Grains', 'Dairy', 'Meats', 'Condiments', 'Seasonings', 'Others'];
final List<IconData> icons = <IconData>[FontAwesomeIcons.appleAlt, FontAwesomeIcons.carrot, FontAwesomeIcons.breadSlice, FontAwesomeIcons.cheese, FontAwesomeIcons.drumstickBite, FontAwesomeIcons.wineBottle, FontAwesomeIcons.pepperHot, FontAwesomeIcons.pizzaSlice];

// Main page
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Store different pages. Index 0 is Ingredients page, 1 is My Recipes, 3 is FAQ
  final List<Widget> _children = [
    new Container(child: new Column(children: <Widget>[
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
            key: _scaffoldKey,
            appBar: AppBar(
              leading: Icon(menuIcons[_selectedIndex]),
              title: Text(_appBar[_selectedIndex], style: new TextStyle(fontSize: 25.0)),
              backgroundColor: Colors.teal,
              actions: <Widget>[
                _selectedIndex == 0 ?
                IconButton(
                    icon: new Icon(Icons.add),
                    onPressed: () => _asyncAddIngrDialog(context, _scaffoldKey)
                ) : Container(width: 0, height: 0),
                _selectedIndex == 0 ?
                IconButton(
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
            bottomNavigationBar: bottomNavBar(_selectedIndex, _onItemTapped),
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

  Future<String> _asyncAddIngrDialog(BuildContext context,
      GlobalKey<ScaffoldState> key) async {
    String newIngredient = '';
    DateTime expiryDate;
    bool isSwitched = false;

    callbackString(name) {
      setState(() {
        newIngredient = name;
      });
    }

    callbackDate(date) {
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
                addNewOwnedIngredient(key, newIngredient, isSwitched,
                    expiryDate);
              },
            ),
          ],
        );
      },
    );
  }
}

// Create navigation bar at the bottom of the screen
Widget bottomNavBar(int currentIndex, Function onTap) {
  return BottomNavigationBar(
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
    currentIndex: currentIndex,
    selectedItemColor: Colors.teal,
    onTap: onTap,
  );
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
                  ]),
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
                          color: element.getExpirationColour(),
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


