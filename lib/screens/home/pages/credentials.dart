// Flutter imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:eduserveMinimal/edu_serve.dart';
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:eduserveMinimal/service/login.dart';

class Credentials extends StatelessWidget {
  bool? pushHomePage = false;
  Credentials({this.pushHomePage});

  @override
  Widget build(BuildContext context) {
    TextEditingController _usernameController = new TextEditingController();
    TextEditingController _passwordController = new TextEditingController();

    void setDefaults() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _usernameController.text = prefs.getString("username") ?? "";
      _passwordController.text = prefs.getString("password") ?? "";
    }

    setDefaults();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Text("Enter Credentials", style: TextStyle(fontSize: 30)),
                SizedBox(height: 20),
                buildTextField(
                    _usernameController, 'Enter your register number.', false),
                SizedBox(height: 20),
                buildTextField(
                    _passwordController, 'Enter your password.', true),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text("Save"),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Verifying credentials...",
                                      style: TextStyle(fontSize: 25),
                                    ),
                                  ),
                                  CircularProgressIndicator(),
                                ],
                              ),
                            ));
                    String loginStatus = await login(
                        _usernameController.text, _passwordController.text);
                    Navigator.of(context).pop();

                    if (loginStatus == "Login error") {
                      Fluttertoast.showToast(msg: "Login error");
                      return;
                    }

                    await prefs.setString("username", _usernameController.text);
                    await prefs.setString("password", _passwordController.text);
                    Fluttertoast.showToast(
                        msg: "Credentials updated successfully");

                    cacheBirthDate();

                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => HomeController()));
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
                ),
                SizedBox(height: 50),
                FutureBuilder(
                    future: SharedPreferences.getInstance(),
                    builder:
                        (context, AsyncSnapshot<SharedPreferences> snapshot) {
                      return snapshot.hasData
                          ? Visibility(
                              visible: snapshot.data!.containsKey("username"),
                              child: ElevatedButton(
                                onPressed: () => Fluttertoast.showToast(
                                    msg: "Press and hold for action"),
                                onLongPress: () => logout(context),
                                child: Text("Logout"),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (states) => Colors.red),
                                ),
                              ),
                            )
                          : Container();
                    })
              ],
            ),
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

  void logout(BuildContext context) {
    bool isLogOutClicked = false;

    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text("Logout"),
                content: Text("Are you sure you want to logout?"),
                actions: [
                  TextButton(
                    onPressed: () async {
                      setState(() => isLogOutClicked = true);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove("username");
                      await prefs.remove("password");

                      Fluttertoast.showToast(msg: "Logout completed");
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          "/credentials", (route) => false);
                    },
                    child: isLogOutClicked
                        ? SizedBox(width: 80, child: LinearProgressIndicator())
                        : Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.green),
                    ),
                  ),
                ],
              );
            }));
  }

  Future<void> cacheBirthDate() async {
    Response res = await get(
        Uri.parse("https://eduserve.karunya.edu/Student/PersonalInfo.aspx"),
        headers: httpHeaders);
    Beautifulsoup soup = Beautifulsoup(res.body);

    String? dateString = soup
        .find_all("input")
        .where((element) => element.id == "ctl00_mainContent_TXTDOB_dateInput")
        .first
        .attributes["value"];

    if (dateString != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("birthDay", dateString);
    }
  }
}
