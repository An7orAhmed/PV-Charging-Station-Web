import 'package:charger_station_web/home.dart';
import 'package:charger_station_web/login.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

void main() {
  final LocalStorage storage = LocalStorage('data');
  bool isLoggedIn = storage.getItem("login") ?? false;
  runApp(MaterialApp(
    title: "Charger Station",
    debugShowCheckedModeBanner: false,
    routes: {
      "/": (context) => isLoggedIn ? HomePage() : LoginPage(),
      "/home": (context) => HomePage(),
      "/login": (context) => LoginPage()
    },
  ));
}
