import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//Useful lists
final List<IconData> menuIcons = <IconData>[Icons.kitchen, Icons.favorite, Icons.lightbulb_outline, Icons.info];
final List<String> categories = <String>['Fruits', 'Vegetables', 'Starch', 'Dairy', 'Meats', 'Sweeteners', 'Condiments', 'Seasonings', 'Beverages', 'Others'];
final List<IconData> icons = <IconData>[FontAwesomeIcons.appleAlt, FontAwesomeIcons.carrot, FontAwesomeIcons.breadSlice, FontAwesomeIcons.cheese, FontAwesomeIcons.drumstickBite, FontAwesomeIcons.candyCane, FontAwesomeIcons.wineBottle, FontAwesomeIcons.pepperHot, FontAwesomeIcons.cocktail, FontAwesomeIcons.pizzaSlice];
final List<String> appBar = ['Ingredients', 'My Recipes', 'Reduce Food Waste', 'About'];


// Schedule a push notification
Future<void> scheduleNotification(FlutterLocalNotificationsPlugin notifications,
    String ingredient, DateTime scheduled, int daysBefore) async {
  //TODO: Debug print
  print('Days before: $daysBefore');
  print(scheduled.toString());

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

// Return current date with hour, minute, second set to 0
DateTime getNormalisedCurrentDate() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
