import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'ingredients.dart';

//Useful lists
final List<IconData> menuIcons = <IconData>[Icons.kitchen,Icons.local_dining, FontAwesomeIcons.pagelines];
final List<String> categories = <String>['Fruits', 'Vegetables', 'Carbs', 'Dairy', 'Meats', 'Sweeteners', 'Condiments', 'Seasonings', 'Others'];
final List<IconData> icons = <IconData>[FontAwesomeIcons.appleAlt, FontAwesomeIcons.carrot, FontAwesomeIcons.breadSlice, FontAwesomeIcons.cheese, FontAwesomeIcons.drumstickBite, FontAwesomeIcons.candyCane, FontAwesomeIcons.wineBottle, FontAwesomeIcons.pepperHot, FontAwesomeIcons.cocktail];
final List<String> appBar = ['Ingredients','Recipe Suggestions', 'Reduce Food Waste'];

final notifications = FlutterLocalNotificationsPlugin();

// Schedule a push notification
Future<void> scheduleNotification(String ingredient, DateTime scheduled, int daysBefore) async {
  NotificationDetails platformChannelSpecifics = _getChannelSpecifics();
  await notifications.schedule(
      getIngredientElement(ingredient).id,
      'Food For Thought',
      'Your ${ingredient.toLowerCase()} will expire in ${daysBefore} day${(daysBefore > 1) ? 's' : ''}',
      scheduled,
      platformChannelSpecifics);
}

NotificationDetails _getChannelSpecifics() {
  var androidPlatformChannelSpecifics =
  new AndroidNotificationDetails(
      '1',
      'Reminder',
      'Ingredient expiration reminder',
      icon: 'app_icon',
      importance: Importance.Max,
      priority: Priority.High,
      ongoing: true);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  return NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);;
}

Future<void> cancelNotification(String ingredient) async {
  int id = getIngredientElement(ingredient).id;
  notifications.cancel(id);
}

// Return current date with hour, minute, second set to 0
DateTime getNormalisedCurrentDate() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

