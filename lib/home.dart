import 'dart:convert';

import 'package:charger_station_web/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

import 'charger.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({super.key});

  final LocalStorage storage = LocalStorage('data');
  List<Charger> chargers = [];

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      timeInSecForIosWeb: 2,
      webPosition: "center",
      webBgColor: "linear-gradient(to right, #2687ff, #9021ff)",
    );
  }

  Future<void> loadChargers() async {
    String stationId = storage.getItem("station_id");
    String param = "action=stationChargers&station_id=$stationId";
    var resp = await http.get(Uri.parse("https://esinebd.com/projects/chargerStation/api.php?$param"));

    if (resp.body.contains("No chargers")) {
      showToast("No Charger found!");
      return;
    } else {
      List<dynamic> json = jsonDecode(resp.body);
      chargers.clear();
      for (Map<String, dynamic> element in json) {
        chargers.add(Charger.fromMap(element));
      }
    }
  }

  Widget button(String title, Icon icon, action) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: action,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
            children: [
              icon,
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  void addCustomer(context) {
    var email = TextEditingController();
    var pass = TextEditingController();
    var name = TextEditingController();
    var phone = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add new customer"),
          content: SizedBox(
            height: 320,
            width: 500,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return TextField(
                      controller: email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        contentPadding: EdgeInsets.symmetric(vertical: 5),
                      ),
                    );
                  case 1:
                    return TextField(
                      controller: pass,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        contentPadding: EdgeInsets.symmetric(vertical: 5),
                      ),
                    );
                  case 2:
                    return TextField(
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        contentPadding: EdgeInsets.symmetric(vertical: 5),
                      ),
                    );
                  case 3:
                    return TextField(
                      controller: phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        contentPadding: EdgeInsets.symmetric(vertical: 5),
                      ),
                    );
                  case 4:
                    return FilledButton(
                      onPressed: () {},
                      child: const Text("Add Customer"),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
              separatorBuilder: (context, i) => const SizedBox(height: 20),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = storage.getItem("login") ?? false;
    if (!isLoggedIn) LoginPage();
    return Scaffold(
      appBar: AppBar(
        title: const Text("PV Charger Station"),
        actions: [
          IconButton(
              onPressed: () {
                storage.clear();
                storage.setItem("login", false);
                Navigator.of(context).popAndPushNamed("/login");
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: FutureBuilder(
          future: loadChargers(),
          builder: (context, data) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  height: double.infinity,
                  width: 800,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("You are logged in as,"),
                        const SizedBox(height: 8),
                        Text(
                          storage.getItem("email") ?? "NULL",
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            button("Add\nCustomer", const Icon(Icons.add_circle, color: Colors.blueAccent, size: 50),
                                () => addCustomer(context)),
                            const SizedBox(width: 10),
                            button("Recharge\nCustomer",
                                const Icon(Icons.monetization_on, color: Colors.purpleAccent, size: 50), () {}),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text("Chargers", style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 15),
                        Column(
                          children: chargers
                              .map(
                                (charger) => Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ListTile(
                                      leading: CircleAvatar(child: Text(charger.id)),
                                      title: Text("Charger State: ${charger.charger_state}"),
                                      trailing: Text("Rate: ${charger.rate}TK/min"),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
