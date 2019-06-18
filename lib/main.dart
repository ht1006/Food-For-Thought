import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'seachbar.dart';
import 'database.dart';
import 'ingredients.dart';
import 'utils.dart';
import 'recipesPage.dart';
import 'tipsPage.dart';
import 'addRecipe.dart';

// Main page
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

// Home page

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => new _HomeState();
}
class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _enableSearch = false;
  bool _refresh = false;
  int _selectedIndex = 0;

  //Store different pages. Index 0 is Ingredients page, 1 is My Recipes, 3 is FAQ
  final List<Widget> _children = [
    Container(),
    RecipeGen(),
    SaveThePlanetPage()
  ];

  // Setting up for push notifications
  @override
  void initState() {
    super.initState();

    final settingsAndroid = AndroidInitializationSettings('app_icon');
    final settingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload)
        => _onSelectNotification(payload));
    notifications.initialize(
        InitializationSettings(settingsAndroid, settingsIOS),
        onSelectNotification: _onSelectNotification);
  }

  Future _onSelectNotification(String payload) async => await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Home()),
  );


  @override
  Widget build(BuildContext context) {
    getAllIngredientsList().then((result) => allIngredients = result);
    return FutureBuilder(
        future: openAppDatabase(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return Container();

          db = snapshot.data;
          return (_selectedIndex == 0) ?
          Scaffold(
            key: _scaffoldKey,
            appBar: _getAppBar(),
            body:  _homePage(),
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
                backgroundColor: Colors.teal,
                onPressed: () => _asyncAddIngrDialog(context, _scaffoldKey)
            ), // FloatingActionButton
            bottomNavigationBar: bottomNavBar(_selectedIndex, _onItemTapped),
          ) // Scaffold
              :
          Scaffold(
            appBar: _getAppBar(),
            body: _children[_selectedIndex],
            bottomNavigationBar: bottomNavBar(_selectedIndex, _onItemTapped),
          ); // Scaffold

        }
    ); // FutureBuilder

  }

  // Get the ingredients page
  Widget _homePage() {
    return Container(
      child: new Column(
        children: <Widget>[
          _enableSearch ? new SearchBar() : new Container(width: 0, height: 0),
          _getCategoryLists()
        ], //children[Widget]
      ), // Column
    ); // Container
  }

  Widget _getAppBar() {
    return AppBar(
      leading: Icon(menuIcons[_selectedIndex]),
      backgroundColor: Colors.teal,
      actions: _getAppBarWidgets(),
      title: Text(
          appBar[_selectedIndex],
          style: new TextStyle(fontSize: MediaQuery.of(context).size.width * 0.063)
      ), // Text
    ); // AppBar
  }



  // Icons at the tob of the screen (app bar)
  List<Widget> _getAppBarWidgets() {
    return [
      _selectedIndex == 0 ?
      IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              _enableSearch = !_enableSearch;
            });
          }
      ) : Container(width: 0, height: 0),
      Row(children: <Widget>[
        _selectedIndex == 1 ?
        IconButton(
          icon: Icon(FontAwesomeIcons.pen),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddRecipe()),
            );
          },
        ) : Container(width: 0, height: 0),// IconButton

        IconButton(
          icon: Icon(Icons.favorite),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LikedRecipeGen()),
            );
          },
        ),// IconButton
      ],)
    ];
  }

  Widget _getCategoryLists() {
    return Expanded(
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
    ); // Expanded
  }

  // Set state methods
  void refreshPage() {
    setState(() {
      _refresh = !_refresh;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Shows a dialog for adding ingredients
  Future<String> _asyncAddIngrDialog(BuildContext context,
      GlobalKey<ScaffoldState> key) async {

    String newIngredient = '';
    bool isSwitched = false;
    DateTime expiryDate;
    bool notify = false;
    int daysBefore = 3;
    TimeOfDay time = TimeOfDay(hour: 17, minute: 0);

    void callbackString(String value) {setState(() {newIngredient = value;});}
    void callbackSwitch(bool value) {setState(() {isSwitched = value;});}
    void callbackExpiry(DateTime value) {setState(() {expiryDate = value;});}
    void callbackNotify(bool value) {setState(() {notify = value;});}
    void callbackDays(int value) {setState(() {daysBefore = value;});}
    void callbackTime(TimeOfDay value) {setState(() {time = value;});}

    return showDialog<String>(
      context: context,
      barrierDismissible: true, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Ingredient'),
          content:
          Container(
              width: 300,
              height: 250,
              child: AddIngredient(newIngredient, isSwitched, expiryDate, notify, daysBefore, time,
                  callbackString, callbackSwitch, callbackExpiry, callbackNotify, callbackDays, callbackTime)
          ), // Container
          actions: <Widget>[
            RaisedButton(
              color: Colors.teal,
              textColor: Colors.white,
              child: Text('ADD'),
              onPressed: () {
                Navigator.of(context).pop(newIngredient);
                bool added = addNewOwnedIngredient(key, newIngredient, isSwitched, expiryDate);
                if (added && notify) {
                  DateTime scheduled
                  = expiryDate.subtract(Duration(days: daysBefore))
                      .add(Duration(hours: time.hour, minutes: time.minute));

                  scheduleNotification(newIngredient, scheduled, daysBefore);

                }
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
        icon: new Icon(Icons.local_dining),
        title: new Text('Recipefy'),
      ),
      BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.pagelines),
          title: Text('Go Green')
      )
    ],
    currentIndex: currentIndex,
    selectedItemColor: Colors.teal,
    onTap: onTap,
  );
}

//Ingredient dropdown
class ExpandableListView extends StatefulWidget {
  final int index;
  List<OwnedIngredient> ingredientsList = [];
  Function() refresh;

  ExpandableListView({Key key, this.index, this.ingredientsList, this.refresh})
      : super(key: key);

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
          _getCategoryHeader(),
          _getCategoryBody(),
        ], // children[Widget]
      ), // Column
    ); // Container
  }

  Widget _getCategoryHeader() {
    return Container(
      child: Row(
        children: <Widget>[
          new Icon(icons[widget.index]),
          Padding(padding: const EdgeInsets.all(10.0)),
          new Text(
            categories[widget.index], style: TextStyle(fontSize: 19),
          ),
          Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      expandFlag ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 30.0,
                    ), //Icon
                    onPressed: () {
                      setState(() {
                        expandFlag = !expandFlag;
                      });
                    }
                ), //IconButton
              ] // children[Widget]
          ), // Row
        ], //childre[Widget]
      ), // Row
    ); // Container
  }

  Widget _getCategoryBody() {
    return ExpandableContainer(
        expanded: expandFlag,
        index: widget.ingredientsList.length,
        child: new ListView.builder(
          itemCount: widget.ingredientsList.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return _getSlide(index);
          },
        ) //ListView
    ); // ExpandableContainer
  }

  Widget _getSlide(int index) {
    OwnedIngredient element = widget.ingredientsList[index];
    return Slidable(
      direction: Axis.horizontal,
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.2,
      child: Container(
          child: new Row(
            children: <Widget>[
              new Icon(Icons.arrow_right, color: Colors.red, size: 25,),
              new Expanded(child: new ListTile(title: new Text(element.name),)),
              new FlatButton(
                  onPressed: () {},
                  shape: StadiumBorder(),
                  color: element.getExpirationColour(),
                  textColor:Colors.white,
                  child: Text(element.getExpirationText()
                  )
              ), // FlatButton
              new Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0))
            ], // children[Widget]
          ) // Row
      ), // Container
      actions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            String ingredient = widget.ingredientsList[index].name;
            removeOwnedIngredient(ingredient).whenComplete(() {
              widget.refresh();
            });
          },
        ), // IconSlideAction
      ], // actions[Widget]
    ); // Slidable
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