import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Creds extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController _usernameController = new TextEditingController();
    TextEditingController _passwordController = new TextEditingController();
    TextEditingController _starsController = new TextEditingController();

    void setDefaults() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _usernameController.text = prefs.getString("username");
      _passwordController.text = prefs.getString("password");
      _starsController.text = (prefs.getInt("stars") == null) ? "1" : prefs.getInt("stars").toString();
    }

    setDefaults();

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTextField(
                _usernameController, 'Enter your register number.', false),
            SizedBox(height: 20),
            buildTextField(_passwordController, 'Enter your password.', true),
            SizedBox(height: 20),
            buildTextField(_starsController,
                'Number of stars to fill in feedback form', false),
            SizedBox(height: 20),
            RaisedButton(
              child: Text("Save"),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString("username", _usernameController.text);
                prefs.setString("password", _passwordController.text);
                prefs.setInt("stars", int.parse(_starsController.text));
                Fluttertoast.showToast(msg: "Credentials update successfuly");
                Navigator.pop(context);
              },
            )
          ],
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
