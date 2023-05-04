import 'package:charger_station_web/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Charger Station",
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
