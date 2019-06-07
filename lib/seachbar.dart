//search bar in the home page
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

import 'database.dart';
import 'ingredients.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<OwnedIngredient>> key = new GlobalKey();

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

  // Suggestion of an OwnedIngredient for autoCompleteTextField
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
}