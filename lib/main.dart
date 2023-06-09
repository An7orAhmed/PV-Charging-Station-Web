import 'package:charger_station_web/home.dart';
import 'package:charger_station_web/login.dart';
import 'package:charger_station_web/state.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_strategy/url_strategy.dart';

// flutter build web --release --base-href "/"

void main() {
  final LocalStorage storage = LocalStorage('data');
  bool isLoggedIn = storage.getItem("login") ?? false;
  setPathUrlStrategy();
  runApp(MaterialApp(
    title: "Charger Station",
    debugShowCheckedModeBanner: false,
    routes: {
      "/": (context) => isLoggedIn ? HomePage() : LoginPage(),
      "/home": (context) => HomePage(),
      "/login": (context) => LoginPage(),
      "/state": (context) => const ChargerState(),
    },
  ));
}
