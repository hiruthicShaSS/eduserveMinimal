// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:eduserveMinimal/themes/themes.dart';
import 'package:eduserveMinimal/views/creds.dart';
import 'package:eduserveMinimal/views/settings/developer.dart';

class Settings extends StatelessWidget {
  static final thisAppPublishDate = "2020-12-20 19:38:07.569667";
  final String eduserveURL =
      "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2f";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ElevatedButton(
              child: Text("Themes"),
              onPressed: () async {
                CustomTheme themes = new CustomTheme();
                List theme = await themes.getTheme();

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text("Themes"),
                            centerTitle: true,
                          ),
                          body: Container(
                              alignment: Alignment.center,
                              child: ListView.builder(
                                itemCount: theme[1].length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(theme[1][index]),
                                    leading: Icon(Icons.thumb_up),
                                    onTap: () {
                                      themes.setTheme(theme[1][index]);
                                    },
                                  );
                                },
                              )),
                        )));
                // Fluttertoast.showToast(msg: "Feature comming soon! ☺", fontSize: 16);
              },
            ),
            ElevatedButton(
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
            ElevatedButton(
              child: Text("Update credentials"),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => Creds()));
              },
            ),
            ElevatedButton(
                child: Text("Check updates"),
                onPressed: () async {
                  if (await canLaunch(
                      "https://github.com/hiruthic2002/eduserveMinimal/releases")) {
                    launch(
                        "https://github.com/hiruthic2002/eduserveMinimal/releases");
                  }
                }),
            ElevatedButton(
              child: Text("About"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Developer()));
              },
            )
          ],
        ),
      ),
    );
  }
}
