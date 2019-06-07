import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

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
          decoration: new BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Color.fromRGBO(201, 228, 201, 0.5)),
          child: new Column(
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(12, 25, 12, 12),
                    child: Text(tipTitle[index], style: TextStyle(fontWeight:
                    FontWeight.bold, fontSize: MediaQuery.of(context).size
                        .height * 0.035), textAlign: TextAlign.center,)),
                Padding(padding: const EdgeInsets.all(8.0), child:Image(image: NetworkImage(images[index]), fit: BoxFit.contain)),
                Padding(padding: const EdgeInsets.fromLTRB(20, 12, 12, 12), child: Text(tip[index], style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025)))]
          ),
        );
      },
      itemCount: tip.length,
      control: new SwiperControl(color: Colors.teal),
    );
  }

}