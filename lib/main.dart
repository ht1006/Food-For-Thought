import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'database.dart';
import 'recipes.dart';
import 'ingredients.dart';
import 'tipsPage.dart';


//Useful lists
final List<IconData> menuIcons = <IconData>[Icons.kitchen, Icons.favorite, Icons.lightbulb_outline, Icons.info];
final List<String> categories = <String>['Fruits', 'Vegetables', 'Starch', 'Dairy', 'Meats', 'Sweeteners', 'Condiments', 'Seasonings', 'Beverages', 'Others'];
final List<IconData> icons = <IconData>[FontAwesomeIcons.appleAlt, FontAwesomeIcons.carrot, FontAwesomeIcons.breadSlice, FontAwesomeIcons.cheese, FontAwesomeIcons.drumstickBite, FontAwesomeIcons.candyCane, FontAwesomeIcons.wineBottle, FontAwesomeIcons.pepperHot, FontAwesomeIcons.cocktail, FontAwesomeIcons.pizzaSlice];

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
  static bool refresh = false;
  int _selectedIndex = 0;
  final List<String> _appBar = ['Ingredients', 'My Recipes', 'Reduce Food Waste', 'About'];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Store different pages. Index 0 is Ingredients page, 1 is My Recipes, 3 is FAQ
  final List<Widget> _children = [
    Center(child: Text(
      'Put loading page here',
      style: TextStyle(fontSize: 30),
    )),
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


  final notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    final settingsAndroid = AndroidInitializationSettings('app_icon');
    final settingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          await notifications.cancel(0);
          onSelectNotification(payload);
        });

    notifications.initialize(
        InitializationSettings(settingsAndroid, settingsIOS),
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async => await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Home()),
  );

  Future<void> scheduleNotification(String ingredient, DateTime expiryDate, DateTime scheduled, int daysBefore) async {
    //TODO: Debug print
    print('Days before: ${daysBefore}');
    print(expiryDate.toString());

    var androidPlatformChannelSpecifics =
    new AndroidNotificationDetails(
        '1',
        'Reminder',
        'Ingredient expiration reminder',
        icon: 'app_icon',
        importance: Importance.Max,
        priority: Priority.High,
        ongoing: true,
        autoCancel: false);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await notifications.schedule(
        0,
        'Food For Thought',
        'Your ${ingredient.toLowerCase()} will expire in ${daysBefore} day${(daysBefore > 1) ? 's' : ''}',
        scheduled,
        platformChannelSpecifics);
  }

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
              title: Text(_appBar[_selectedIndex], style: new TextStyle(fontSize: MediaQuery.of(context).size.width * 0.063)),
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
            resizeToAvoidBottomInset : false,
            body: _selectedIndex == 0 ?
            new Container(
              child: new Column(
                children: <Widget>[
                  enableSearch ? new SearchBar() : new Container(width: 0, height: 0),
                  new Expanded(
                    child: new ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return FutureBuilder(
                          future: getOwnedIngredientList(categories[index]),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {

                            if (snapshot.hasData) {
                              List<OwnedIngredient> list = snapshot.data;
                              list.sort((a, b) => (a.expires == null) ? 1 :
                              (b.expires == null) ? -1 :
                              a.expires.compareTo(b.expires));

                              return ExpandableListView(index: index, ingredientsList: list, refresh: refreshPage);
                            }
                            return Container(height: 0, width: 0,);
                          },
                        ); // FutureBuilder
                      },
                    ), // ListView
                  ) // Expanded
                ], //children[Widget]
              ), // Column
            ) // Container
                : _children[_selectedIndex],
            bottomNavigationBar: bottomNavBar(_selectedIndex, _onItemTapped),
          ); // Scaffold
        } else {
        return new Container(
              decoration: new BoxDecoration(color: Colors.white),
              child: new Center(
                child: new CircularProgressIndicator(backgroundColor: Colors.teal,
              strokeWidth: 5))
          ); // Container
        }
      }
    ); // FutureBuilder

  }

  void refreshPage() {
    setState(() {
      refresh = !refresh;
    });
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
    DateTime now = DateTime.now();
    DateTime scheduled = DateTime(now.year, now.month, now.day, 17);
    bool isSwitched = false;
    bool notify = false;
    int daysBefore = 3;

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

    callbackScheduled(date) {
      setState(() {
        scheduled = date;
      });
    }

    callbackSwitch(value) {
      setState(() {
        isSwitched = value;
      });
    }

    callbackNotify(value) {
      setState(() {
        notify = value;
      });
    }

    callbackDays(value) {
      setState(() {
        daysBefore = value;
      });
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: true, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Ingredient'),
          content:
//            ListView.builder(
//              itemCount: 1,
//              itemBuilder: (BuildContext context, int index) {
                Container(
                    width: 300,
                    height: 250,
                    child: AddIngredient(newIngredient, isSwitched, expiryDate, scheduled, notify, daysBefore,
                    callbackString, callbackSwitch, callbackDate, callbackScheduled, callbackNotify, callbackDays)
                ), // Container
//              }
//            ), // ListView
          actions: <Widget>[
            RaisedButton(
              color: Colors.teal,
              textColor: Colors.white,
              child: Text('ADD'),
              onPressed: () {
                Navigator.of(context).pop(newIngredient);
                addNewOwnedIngredient(key, newIngredient, isSwitched, expiryDate);
                if (notify)
                  scheduleNotification(newIngredient, expiryDate, scheduled, daysBefore);
                refreshPage();

              },
            ), // RaisedButton
          ], // actions[Widget]
        ); // Dialog box
      },
    ); // showDialog
  } //_asyncAddIngrDialog
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
          title: Text('Go Green')
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
  Widget ownedIngredientRow(OwnedIngredient ownedIngredient) {
    return Container(
      padding: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            ownedIngredient.name,
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(
            width: 25.0,
            height: 30,
          ),
          Text(
            ownedIngredient.category,
          ),
        ],
      ),
    );
  }

  //TODO: Dismiss suggestions when tapped outside the area
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
                return ownedIngredientRow(item);
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
  Function() refresh;

  ExpandableListView({Key key, this.index, this.ingredientsList, this.refresh}) : super(key: key);

  @override
  _ExpandableListViewState createState() => new _ExpandableListViewState();

}

class _ExpandableListViewState extends State<ExpandableListView> {
  bool expandFlag = false;

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
                            widget.refresh();
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


