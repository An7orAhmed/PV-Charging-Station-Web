import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'const.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalStorage storage = LocalStorage('data');

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      timeInSecForIosWeb: 2,
      webPosition: "center",
      webBgColor: "linear-gradient(to right, #2687ff, #9021ff)",
    );
  }

  void login(context, String mail, String pass) async {
    if (mail == '' || pass == '') {
      showToast("Email or Password shouldn't be empty!");
      return;
    }
    String param = "action=login&user_type=admin&email=$mail&password=$pass";
    await http.get(Uri.parse("${host}api.php?$param")).then((resp) {
      if (resp.body.contains("failed")) {
        showToast("Email or password not found!");
        return;
      }
      var stationId = resp.body.replaceAll("Login successful. User ID: ", "");
      storage.setItem("login", true);
      storage.setItem("email", mail);
      storage.setItem("pass", pass);
      storage.setItem("station_id", stationId);
      print("$mail, $pass, $stationId");
      showToast("Login Successful");
      Navigator.of(context).pushReplacementNamed("/home");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 220,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      String email = _emailController.text;
                      String pass = _passwordController.text;
                      login(context, email, pass);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
