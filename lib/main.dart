import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//example database
final List<String> ingredients
= <String>['Fruit', 'Vegetables', 'Dairy', 'Meat', 'Spices'];
List<String> fruits = <String>['apple', 'orange', 'banana'];
List<String> vegs = <String>['broccoli', 'carrots', 'aubergines', 'asparagus'];
List<String> dairy = <String>['milk', 'almond milk'];
List<String> meat = <String>['lamb', 'chicken', 'beef'];
List<String> spices = <String>['chilli powder'];
final List<IconData> icons
      = <IconData>[FontAwesomeIcons.appleAlt, FontAwesomeIcons.carrot, FontAwesomeIcons.cheese
                  , FontAwesomeIcons.drumstickBite, FontAwesomeIcons.pepperHot];

//main page
void main() => runApp(new MaterialApp(home: new Home()));

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.menu),
          title: Text('Ingredients', style: new TextStyle(fontSize: 25.0)),
          backgroundColor: Colors.teal,
        ),
        body: new ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return new ExpandableListView(index: index);
            //return new ExpandableListView(title: '${ingredients[index]}', index: index);
        },
        itemCount: ingredients.length,
      ),
    );
  }
}

class ExpandableListView extends StatefulWidget {
  //final String title;
  final int index;

  const ExpandableListView({Key key, this.index}) : super(key: key);

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
            new Text(
                  ingredients[widget.index], style: TextStyle(fontSize: 20),
                ),
            new IconButton(icon: new Icon(
              expandFlag ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 30.0,
            ),
                onPressed: () {
              setState(() {
                expandFlag = !expandFlag;
              });
            }),
          ],
        ),
        ),
        new ExpandableContainer(
            expanded: expandFlag,
            index: getFoodTypeList(ingredients[widget.index]).length,
            child: new ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return new Container(
                  child: new ListTile(
                    title: new Text(
                      getFoodTypeList(ingredients[widget.index])[index],
                    ),
                  ),
                );},
              itemCount: getFoodTypeList(ingredients[widget.index]).length,
            ))
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

//Return the corresponding specific ingredient list according to the foodType
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










//
////Previous codes
//  Widget _buildIngredients() {
//    return ListView.separated(
//        padding: const EdgeInsets.all(16.0),
//        itemCount: ingredients.length,
//        itemBuilder: (BuildContext context, int index) {
//          return ListTile(
//            leading: Icon(icons[index]),
//            title: Text('${ingredients[index]}',
//                style: new TextStyle(fontSize: 20.0)),
//            trailing: Row(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>[
//                  Icon(Icons.add),
//                  Padding(padding: const EdgeInsets.all(10.0)),
//                  IconButton(icon: Icon(Icons.arrow_drop_down),
//                      onPressed: () => new ExpandableIngredients(foodType: '${ingredients[index]}'))
//                  ]),
//          );
//        },
//      separatorBuilder: (BuildContext context, int index) => const Divider(),
//    );
//  }
//
//
//class HeaderIngredients extends StatelessWidget {
//  final foodType;
//
//  const HeaderIngredients({Key key, this.foodType}) : super(key:key);
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//
//      body: ExpandableIngredients(foodType: foodType),
//    );
//  }
//
//}
//
//class ExpandableIngredients extends StatelessWidget {
//  final String foodType;
//
//  const ExpandableIngredients({Key key, this.foodType}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    List<String> lists = getFoodTypeList(foodType);
//    final list = List.generate(lists.length, (i) => lists[i]);
//    return new ListView.builder(
//      itemCount: 1,
//      itemBuilder: (context, i) => ExpansionTile(
//        title: new Text(foodType),
//        children: list
//            .map((val) => new ListTile(
//          title: new Text(val),
//        ))
//            .toList(),
//      ),
//    );
//  }
//}