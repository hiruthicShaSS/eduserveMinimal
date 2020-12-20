import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eduserveMinimal/scrap.dart';

class Settings extends StatelessWidget {
  final String eduserveURL =
      "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2f";
  SharedPreferences prefs; // Shared preferences instance
  void setPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    setPrefs();

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            RaisedButton(
              child: Text("Themes"),
              onPressed: () {},
            ),
            RaisedButton(
              child: Text("Update cloud link"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return buildUpdateLinkPage();
                    },
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text("Open EduServe"),
              onPressed: () async {
                if (await canLaunch(eduserveURL)) {
                  await launch(eduserveURL);
                } else {
                  Fluttertoast.showToast(
                      msg: "Can't open EduServe at this moment",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      fontSize: 16.0);
                }
              },
            ),
            RaisedButton(
              child: Text("Check updates"),
              onPressed: () async {
                // Scrapper scrapper = new Scraper();
                // final body = await scrapper.getInfo();
                // Navigator.push(context, MaterialPageRoute(builder: (contenxt) {
                //   return Scaffold(
                //     body: ListView(
                //       children: [
                //         Text(body),
                //       ],
                //     ),
                //   );
                // }));
              },
            ),
            SizedBox(height: _height / 1.58),
            Center(child: Text("Version 1.0 alpha")),
          ],
        ),
      ),
    );
  }

  Scaffold buildUpdateLinkPage() {
    TextEditingController _linkController = new TextEditingController();
    _linkController.text = prefs.getString(
        "link"); // Set the stored link from shared preferences back to the text box

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _linkController,
            decoration: new InputDecoration(
              labelText: "New cloud link",
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(25.0),
                borderSide: new BorderSide(),
              ),
              //fillColor: Colors.green
            ),
            keyboardType: TextInputType.emailAddress,
            style: new TextStyle(
              fontFamily: "Poppins",
            ),
          ),
          SizedBox(height: 10),
          RaisedButton(
            child: Text("Update"),
            onPressed: () async {
              String link = _linkController.text;
              await prefs.setString("link", link);
              Fluttertoast.showToast(msg: "Link updated");
            },
          )
        ],
      ),
    );
  }
}
