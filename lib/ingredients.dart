import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

import 'database.dart';
import 'utils.dart';

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

// Class to represent an owned ingredient
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

  int _getDifferenceInDays() {
    if (expires == null) return -1;
    int difference = expires.difference(getNormalisedCurrentDate()).inDays;
    return (difference < 0) ? -difference : difference;
  }

  bool _hasExpired() {
    return (expires == null) ? false
        : expires.isBefore(getNormalisedCurrentDate());
  }

  Color getExpirationColour() {
    int daysLeft = _getDifferenceInDays();
    return (_hasExpired()) ? Colors.black45 :
    (daysLeft < 0) ? Colors.teal :
    (daysLeft > 7) ? Colors.green :
    (daysLeft > 2) ? Colors.amber : Colors.red;
  }


  String getExpirationText() {
    int difference = _getDifferenceInDays();
    String plural = (difference > 1) ? 's' : '';
    return (difference == -1) ? "No expiration date" :
    (difference == 0) ? "Expired today" :
    (_hasExpired()) ? "Expired for $difference day$plural" :
    (difference < 31) ? "Expires in $difference day$plural"
        : "Expires ${expires.day}/${expires.month}/${expires.year}";
  }

}


// Add ingredient dialog box content
class AddIngredient extends StatefulWidget {

  String newIngredient;
  bool isSwitched;
  DateTime expiryDate;
  bool notify;
  int daysBefore;
  TimeOfDay time;
  Function(String) callbackString;
  Function(bool) callbackSwitch;
  Function(DateTime) callbackExpiry;
  Function(bool) callbackNotify;
  Function(int) callbackDays;
  Function(TimeOfDay) callbackTime;


  AddIngredient(this.newIngredient, this.isSwitched, this.expiryDate, this.notify, this.daysBefore, this.time,
      this.callbackString, this.callbackSwitch, this.callbackExpiry, this.callbackNotify, this.callbackDays, this.callbackTime);

  @override
  _AddIngredientState createState() => new _AddIngredientState();
}

class _AddIngredientState extends State<AddIngredient> {
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Ingredient>> key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    List<Widget> dialogList = [
      searchTextField = _getAutoCompleteTextField(),
      Padding(padding: const EdgeInsets.all(10.0)),
      _getExpirationRow(),
      Padding(padding: const EdgeInsets.all(5)),
      _getReminderTitle(),
      Padding(padding: const EdgeInsets.all(5)),
      _getReminderDaysRow(),
      _getReminderTimeRow()
    ];

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: dialogList.length,
            itemBuilder: (BuildContext context, int index) {
              return dialogList[index];
            },
          ) // ListView
        ) // Expanded
      ], // children[Widget]
    ); // Column
  }

  /// WIDGET METHODS


  // A suggestion row for an ingredient to add
  Widget _ingredientSuggestion(Ingredient item) {
    return Container(
      padding: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey))
      ),
      child: Text(
        item.name,
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }

  AutoCompleteTextField<Ingredient> _getAutoCompleteTextField() {
    return AutoCompleteTextField<Ingredient>(
      key: key,
      clearOnSubmit: false,
      suggestions: allIngredients,
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
          widget.newIngredient = item.name;
          widget.callbackString(item.name);

          widget.expiryDate = item.expires;
          widget.callbackExpiry(item.expires);

          searchTextField.clear();
          searchTextField.textField.controller.text = item.name;
        });
      },
      itemBuilder: (context, item) {
        // ui for the autocompelete row
        return _ingredientSuggestion(item);
      },
    ); // AutoCompleteTextField
  }

  // Set expiration date for the item
  Widget _getExpirationRow() {
    return Row(
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
        ), // Switch
        Padding(padding: const EdgeInsets.all(10.0)),
        new RaisedButton(
            child: Text(
                (widget.isSwitched && widget.expiryDate != null) ?
                '${widget.expiryDate.day}/${widget.expiryDate.month}/${widget.expiryDate.year}'
                    : 'Add Expiry Date'
            ),
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
                widget.expiryDate = date;
                widget.callbackExpiry(date);
              });
            });
            }
        ) // RaisedButton
      ], // children[Widget]
    ); // Row
  }

  Widget _getReminderTitle() {
    return Row(
      children: <Widget>[
        Text(
            'Expiration reminder',
            style: TextStyle(
              fontSize: 15,
              color: (widget.isSwitched) ? Colors.black : Colors.grey,
            ) // TextStyle
        ) // Text
      ], // children[Widget]
    ); // Row
  }

  // Set a day for expiration reminder
  Widget _getReminderDaysRow() {
    return new Row(
      children: <Widget>[
        Switch(
          value: widget.isSwitched && widget.notify,
          onChanged: (val) {
            if (widget.isSwitched) {
              setState(() {
                widget.notify = val;
                widget.callbackNotify(val);
              });
            }
          },
          activeTrackColor: Colors.teal,
          activeColor: Colors.teal,
        ), // Switch
        Padding(padding: const EdgeInsets.all(10.0)),
        Container(
          width: 135,
          height: 25,
          child: TextField(
            enabled: widget.isSwitched && widget.notify,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: (widget.notify) ? '${widget.daysBefore}' : 'Days Before'
            ),
            onChanged: (String days) {
                setState(() {
                int daysBefore = int.parse(days);
                widget.daysBefore = daysBefore;
                widget.callbackDays(daysBefore);

              });
            },
          ), // TextField
        ), // Container
      ], // children[Widget]
    ); // Row
  }

  // Pick time for the reminder
  Widget _getReminderTimeRow() {
    return Row(
      children: <Widget>[
        Padding(padding: EdgeInsets.fromLTRB(60, 20, 20, 0)),
        RaisedButton(
            child: Text((widget.notify) ?
                widget.time.toString().substring(10,15)
                : 'Select Time'),
            onPressed: !widget.notify ? null : ()
            {
              showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: 17, minute: 0),
                builder: (BuildContext context, Widget child) {
                  return Theme(
                      data: ThemeData(primaryColor: Colors.teal, accentColor: Colors.teal),
                      child: child
                  );
                }
              ).then((time) {
                setState(() {
                  widget.time = time;
                  widget.callbackTime(time);
                });
              });
            }
        ) // RaisedButton
      ], // children[Widget]
    ); // Row
  }

} // _AddIngredientState



/// FUNCTIONS REGARDING INGREDIENTS

// Functions for adding ingredients to the database
bool addNewOwnedIngredient(GlobalKey<ScaffoldState> key, String newIngredient, bool isSwitched, DateTime expiryDate) {
  getAllOwnedIngredientsList().then((ownedList) {
    if (!_isValidIngredient(key, newIngredient, ownedList))
      return false;

    String category = _getIngredientCategory(newIngredient);
    if (!isSwitched) {
      addOwnedIngredient(category, newIngredient);
    } else {
      addOwnedIngredientWithExpiry(category, newIngredient, expiryDate);
    }
  });
  return true;
}

// Determines the category in which given ingredient belongs
String _getIngredientCategory(String newIngredient) {
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
bool _isValidIngredient(GlobalKey<ScaffoldState> key, String newIngredient, List<String>
ownedList) {
  bool isValid = true;
  if (newIngredient.isEmpty) {
    _showSnackBar(key, 'Invalid ingredient!');
    isValid = false;
  }
  if (ownedList.contains(newIngredient)) {
    _showSnackBar(key, 'Ingredient already added');
    isValid = false;
  }
  return isValid;
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
