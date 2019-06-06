import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

import 'database.dart';

List<Ingredient> allIngredients = [];

// Class to represent an ingredient
class Ingredient {
  final String name;
  final String category;
  final DateTime expires;

  Ingredient({this.name, this.category, this.expires});

  factory Ingredient.decodeJson(Map<String, dynamic> json) {
    int duration = int.parse(json['duration']);
    DateTime date = (duration == 0) ? null :
    getNormalisedCurrentDate().add(Duration(days: duration));
    return Ingredient(
      name: json['name'],
      category: json['category'],
      expires: date,
    );
  }
}

// Class to represent an owned
class OwnedIngredient {
  String name;
  String category;
  DateTime expires;

  OwnedIngredient({Key key, this.name, this.category, this.expires});

  Map<String, dynamic> toMap() {
    return {'name': name, 'category': category, 'expire': expires.toString()};
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

  int getDifferenceInDays() {
    if (expires == null) return -1;
    int difference = expires.difference(getNormalisedCurrentDate()).inDays;
    return (difference < 0) ? -difference : difference;
  }

  bool hasExpired() {
    return (expires == null) ? false
        : expires.isBefore(getNormalisedCurrentDate());
  }

  Color getExpirationColour() {
    int daysLeft = getDifferenceInDays();
    return (hasExpired()) ? Colors.black45 :
    (daysLeft < 0) ? Colors.teal :
    (daysLeft > 7) ? Colors.green :
    (daysLeft > 2) ? Colors.amber : Colors.red;
  }


  String getExpirationText() {
    int difference = getDifferenceInDays();
    return (difference == -1) ? "No expiration date" :
    ((difference == 0) ? "Expired today" :
    ((hasExpired()) ? "Expired for $difference day"
        : "Expires in $difference day") +
        ((difference > 1) ? 's' : ''));
  }

}


// Add ingredient box
class AddIngredient extends StatefulWidget {

  String newIngredient;
  DateTime expiryDate;
  String expirationText = "Add Expiry Date";
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
                  widget.expirationText
                  = widget.expiryDate.toString().substring(0, 11);
                });
              },
              activeTrackColor: Colors.teal,
              activeColor: Colors.teal,
            ),
            Padding(padding: const EdgeInsets.all(10.0)),
            new RaisedButton(
                child: Text(widget.expirationText),
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
                ).then((date) {
                  setState(() {
                    widget.expirationText = date.toString().substring(0, 11);
                    widget.callbackDate(date);
                  });
                });
                }
            )
          ],
        )
      ],
    );
  }
}


// Functions for adding ingredients to the database
void addNewOwnedIngredient(GlobalKey<ScaffoldState> key, String newIngredient, bool isSwitched, DateTime expiryDate) {
  if (newIngredient.isEmpty) return;

  getAllOwnedIngredientsList().then((ownedList) {
    if (!isValidIngredient(key, newIngredient, ownedList))
      return;

    String category = getIngredientCategory(newIngredient);
    if (!isSwitched) {
      addOwnedIngredient(category, newIngredient);
    } else {
      addOwnedIngredientWithExpiry(category, newIngredient, expiryDate);
    }
  });
}

// Determines the category in which given ingredient belongs
String getIngredientCategory(String newIngredient) {
  String category = '';
  for (int i = 0; i < allIngredients.length; i++) {
    Ingredient element = allIngredients[i];
    if (element.name.compareTo(newIngredient) == 0) {
      category = element.category;
      break;
    }
  }
  return category;
}

// Check whether submitted ingredient is valid
bool isValidIngredient(GlobalKey<ScaffoldState> key, String newIngredient, List<String>
ownedList) {
  if (ownedList.contains(newIngredient)) {
    _showSnackBar(key, 'Ingredient already owned');
    return false;
  }
  bool isValid = ingredientListToStringList().contains(newIngredient);
  if (!isValid) _showSnackBar(key, 'Invalid ingredient!');
  return isValid;
}
// Converts list of all ingredients into a list of strings
List<String> ingredientListToStringList() {
  List<String> list = [];
  allIngredients.forEach((ingr) => list.add(ingr.name));
  return list;
}

// Snackbar
void _showSnackBar(GlobalKey<ScaffoldState> key, String text) {
  key.currentState.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: 2),
      )
  );
}
