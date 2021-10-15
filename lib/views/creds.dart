// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:eduserveMinimal/edu_serve.dart';
import 'package:eduserveMinimal/main.dart';

class Creds extends StatelessWidget {
  bool pushHomePage = false;
  Creds({this.pushHomePage});

  @override
  Widget build(BuildContext context) {
    TextEditingController _usernameController = new TextEditingController();
    TextEditingController _passwordController = new TextEditingController();
    TextEditingController _starsController = new TextEditingController();

    void setDefaults() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _usernameController.text = prefs.getString("username");
      _passwordController.text = prefs.getString("password");
      _starsController.text = (prefs.getInt("stars") == null)
          ? "1"
          : prefs.getInt("stars").toString();
    }

    setDefaults();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              buildTextField(
                  _usernameController, 'Enter your register number.', false),
              SizedBox(height: 20),
              buildTextField(_passwordController, 'Enter your password.', true),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Save"),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString("username", _usernameController.text);
                  prefs.setString("password", _passwordController.text);
                  prefs.setInt(
                      "stars", min(int.parse(_starsController.text), 5));
                  Fluttertoast.showToast(msg: "Credentials update successfuly");

                  if (pushHomePage ?? false) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => EduServeMinimal()));
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              SizedBox(height: 30.0),
              Text("Caution!",
                  style: GoogleFonts.kanit(
                    fontSize: 20,
                    color: Colors.red,
                  )),
              Column(
                children: [
                  Row(children: [
                    Icon(Icons.control_point),
                    SizedBox(width: 10),
                    Expanded(
                      child: AutoSizeText(
                        "Refreshing the data too many times will result in banning in eduserve. You will need to reset your password everytime you get banned.",
                        style: GoogleFonts.kanit(),
                        maxFontSize: 30,
                        minFontSize: 15,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  SizedBox(height: 20),
                  Row(children: [
                    Icon(Icons.control_point),
                    SizedBox(width: 10),
                    Expanded(
                      child: AutoSizeText(
                        "If you feel the app doesn't work properly hard restart the app. If that doesnt help file a issue on github.\nSettings -> About -> Request Feature",
                        style: GoogleFonts.kanit(),
                        maxFontSize: 30,
                        minFontSize: 15,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ])
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  TextField buildTextField(
      TextEditingController _starsController, String hint, bool obscure) {
    return TextField(
      controller: _starsController,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
      ),
    );
  }
}
