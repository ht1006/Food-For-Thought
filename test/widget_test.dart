// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_for_thought/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Ingredients'), findsNWidgets(2));
    expect(find.text('Fruit'), findsOneWidget);
    expect(find.text('Vegetables'), findsOneWidget);
    expect(find.text('Dairy'), findsOneWidget);
    expect(find.text('Meat'), findsOneWidget);
    expect(find.text('Spices'), findsOneWidget);
  });
}
