import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'charger.dart';

class ChargerState extends StatefulWidget {
  const ChargerState({super.key});

  @override
  State<ChargerState> createState() => _ChargerStateState();
}

class _ChargerStateState extends State<ChargerState> {
  List<Charger> chargers = [];

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      String param = "action=stationChargers&station_id=1";
      http.get(Uri.parse("https://esinebd.com/projects/chargerStation/api.php?$param")).then((resp) {
        if (resp.body.contains("No chargers")) {
          return;
        } else {
          List<dynamic> json = jsonDecode(resp.body);
          chargers.clear();
          for (Map<String, dynamic> element in json) {
            chargers.add(Charger.fromMap(element));
          }
          setState(() {});
        }
      });
    });
    super.initState();
  }

  Widget chargerCard(Charger charger) {
    return SizedBox(
      height: 600,
      child: Card(
        elevation: 30,
        margin: const EdgeInsets.only(right: 50),
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Charger ID: 0${charger.id}",
                style: const TextStyle(fontSize: 32),
              ),
              if (charger.charger_state == "off")
                Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset("assets/${charger.id}.png", height: 280, width: 280),
                  ),
                )
              else
                const Text(
                  "BUSY RIGHT NOW",
                  style: TextStyle(fontSize: 40, color: Colors.redAccent),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "XYZ CHARGING STATION",
              style: TextStyle(fontSize: 38, color: Colors.blueAccent),
            ),
            Text(
              "STATION ID: 01",
              style: TextStyle(fontSize: 33, color: Colors.blueGrey.shade700),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: chargers
                  .map(
                    (charger) => chargerCard(charger),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
