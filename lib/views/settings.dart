// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:eduserveMinimal/views/creds.dart';
import 'package:eduserveMinimal/views/settings/developer.dart';
import 'package:eduserveMinimal/views/settings/themes.dart';

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
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Themes())),
            ),
            ElevatedButton(
              child: Text("Open EduServe"),
              onPressed: () async {
                await launch(eduserveURL);
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
                  launch(
                      "https://github.com/hiruthic2002/eduserveMinimal/releases");
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
