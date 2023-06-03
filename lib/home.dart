import 'package:charger_station_web/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final LocalStorage storage = LocalStorage('data');

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
    await http.get(Uri.parse("https://esinebd.com/projects/chargerStation/api.php?$param")).then((resp) {
      if (resp.body.contains("No chargers")) {
        showToast("No Charger found!");
        return;
      }
      print(resp.body);
    });
  }

  Widget button(String title, Icon icon, Function action) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {},
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
                                () {}),
                            const SizedBox(width: 10),
                            button("Recharge\nCustomer",
                                const Icon(Icons.monetization_on, color: Colors.purpleAccent, size: 50), () {}),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text("Chargers", style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            button("Add\nCustomer", const Icon(Icons.add_circle, color: Colors.blueAccent, size: 50),
                                () {}),
                            const SizedBox(width: 10),
                            button("Recharge\nCustomer",
                                const Icon(Icons.monetization_on, color: Colors.purpleAccent, size: 50), () {}),
                          ],
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
