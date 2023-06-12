import 'dart:async';
import 'dart:convert';
import 'dart:html';
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
    document.documentElement!.requestFullscreen();
    super.initState();
  }

  Widget chargerCard(Charger charger) {
    return SizedBox(
      height: 400,
      width: 335,
      child: Card(
        elevation: 30,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
        margin: const EdgeInsets.only(right: 50),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                child: Text(
                  "0${charger.id}",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              if (charger.charger_state == "off")
                Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset("assets/${charger.id}.png", height: 200, width: 200),
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
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "XYZ CHARGING STATION",
              style: TextStyle(fontSize: 38, color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
            Text(
              "STATION ID: 01",
              style: TextStyle(fontSize: 33, color: Colors.blueGrey.shade700),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: chargers
                    .map(
                      (charger) => chargerCard(charger),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
