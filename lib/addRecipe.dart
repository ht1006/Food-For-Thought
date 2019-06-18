import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'ingredients.dart';
import 'recipes.dart';
import 'database.dart';

/// Add recipe page
class AddRecipe extends StatefulWidget {

  @override
  _AddRecipeState createState() => new _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {

  List<IngredientUsed> submittedIngredients = [];
  final TextEditingController quantController = new TextEditingController();
  final TextEditingController unitsController = new TextEditingController();

  String recipeName = '';
  String image = '';
  String directions = '';

  int id = 0;
  String ingredient = '';
  String quantity = '';
  String unit = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(
              'Add Your Own Recipe',
              style: new TextStyle(fontSize: MediaQuery.of(context).size.width * 0.063)
          ), // Text
        ), // AppBar
        body:
        SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                padding: const EdgeInsets.all(8.0),
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.fromLTRB(15, 10, 15, 5), child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Text(
                          "Please make sure to include recipes that are quick, easy and require minimal ingredients",
                          style: TextStyle(fontSize: 22, color: Colors.teal),
                        ),
                      ),)),
                    _addOneSection("Title:", "Please Enter Your Recipe Title"),
                    _addOneSection("Picture: ", "Please Enter the Picture URL"),
                    _addIngredientsSection(),
                    Padding(padding: const EdgeInsets.all(5)),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      RaisedButton(child:
                      Text("Add Ingredient",
                        style: TextStyle(fontSize: 16),),
                        onPressed:() {_submitIngredient();},
                        color: Colors.teal,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(15),
                        splashColor: Colors.amber,),
                    ],),

                    Padding(padding: const EdgeInsets.all(5)),

                    Padding(padding: const EdgeInsets.fromLTRB(15, 10, 15, 5), child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Text(
                          "Added Ingredients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),)),

                    Container(child: ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: submittedIngredients.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Padding(padding: const EdgeInsets.fromLTRB(15, 10, 15, 5), child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              child: Text(
                                submittedIngredients[index].display(),
                                style: TextStyle(fontSize: 20),
                              ),
                            ),));
                        }
                    )),

                    _addDirection(),
                    RaisedButton(child: Text("Submit the Recipe",
                      style: TextStyle(fontSize: 18),),
                      onPressed: () {_submitRecipe();},
                      color: Colors.teal,
                      padding: EdgeInsets.all(20),
                      textColor: Colors.white,
                      splashColor: Colors.amber,),
                  ],)))
    ); // Scaffold
  }

  _submitIngredient() {
    submittedIngredients.add(
        IngredientUsed(id: id,
            ingredientName: ingredient,
            quantity: int.parse(quantity),
            unit: unit
        ));
    id = 0;
    ingredient = '';
    quantity = '';
    unit = '';
    quantController.clear();
    unitsController.clear();
    searchTextField.clear();
    setState(() {});
  }


  _submitRecipe() {
    uploadNewRecipe(Recipe(
      name: recipeName,
      directions: directions,
      image: image,
      ingredientsUsed: submittedIngredients,
    ));
  }

  Widget _addOneSection(String title, String insideSearch) {
    return Column(children: <Widget>[
      Padding(padding: const EdgeInsets.fromLTRB(15, 10, 15, 5), child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          child: Text(
            title, style: TextStyle(fontSize: 22),

          ),
        ),)),
      Padding(padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
        child: TextField(
          textCapitalization: (title == "Title:") ? TextCapitalization.words : TextCapitalization.none,
          onChanged: (text) => (title == "Title:") ? recipeName = text : image = text,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: EdgeInsets.all(20.0),
          hintText: insideSearch,
          hintStyle: TextStyle(color: Colors.black),
        ),),)
    ],
    );
  }

  Widget _addDirection() {
    return Column(children: <Widget>[
      Padding(padding: const EdgeInsets.fromLTRB(15, 10, 15, 6), child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          child: Text(
            "Directions", style: TextStyle(fontSize: 22),
          ),
        ),)),

      Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: new ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 200.0,
          ),
          child: new Scrollbar(
            child: new SingleChildScrollView(
              scrollDirection: Axis.vertical,
              reverse: true,
              child: SizedBox(
                height: 200.0,
                child: new TextField(
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (text) => directions = text,
                  maxLines: 100,
                  decoration: new InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Add Your Direction Here',
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),),),
        ),)
    ],);
  }

  //enter your ingredients
  Widget _addIngredientsSection() {
    return Column(children: <Widget>[
      Padding(padding: const EdgeInsets.fromLTRB(15, 10, 15, 5), child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          child: Text(
            "Enter your Ingredients", style: TextStyle(fontSize: 22),
          ),
        ),)),
      Row(children: <Widget>[
        Padding(padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
          child: _smallSectionInIngredient("Quant", 0.25),),
        _smallSectionInIngredient("Unit", 0.2),
        _getAutoCompleteTextField(),

      ],)
    ],);
  }

  //i.e. quant/unit
  Widget _smallSectionInIngredient(String searchField, double width) {
    return Container(
      width: MediaQuery.of(context).size.width*width,
      child: Padding(padding: const EdgeInsets.all(2.0),
        child:TextField(
          keyboardType: (searchField == "Quant") ? TextInputType.number : TextInputType.text,
         decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: EdgeInsets.all(20.0),
          hintText: searchField,
          hintStyle: TextStyle(color: Colors.black),
        ),
        onChanged: (text) {
          searchField == "Quant" ? quantity = text : unit = text;
        },
        controller: searchField == "Quant" ? quantController : unitsController,
      ),),);
  }

  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Ingredient>> key = new GlobalKey();

  Widget _getAutoCompleteTextField() {
    return Container(
        width: MediaQuery.of(context).size.width*0.4,
        child: searchTextField = AutoCompleteTextField<Ingredient>(
          key: key,
          clearOnSubmit: false,
          suggestions: allIngredients,
          style: TextStyle(color: Colors.black, fontSize: 16.0),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            suffixIcon: Icon(Icons.search, color: Colors.black),
            hintText: "Ingredient",
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
              ingredient = item.name;
              id = item.id;

              //TODO: why the rows aren't going away
              //TODO: why text is not the selected text
              searchTextField.clear();
              searchTextField.textField.controller.text = item.name;
            });
          },
          itemBuilder: (context, item) {
            // ui for the autocomplete row
            return _ingredientSuggestion(item);
          },
        ) // AutoCompleteTextField,
    );
  }

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
}
