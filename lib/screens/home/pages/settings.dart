// Flutter imports:
import 'package:eduserveMinimal/screens/home/pages/cache_data.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_version/new_version.dart';

// Package imports:
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:eduserveMinimal/screens/home/pages/credentials.dart';
import 'package:eduserveMinimal/screens/settings/pages/attribution.dart';
import 'package:eduserveMinimal/screens/settings/pages/developer.dart';
import 'package:eduserveMinimal/screens/settings/pages/themes.dart';

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
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text("Themes"),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => Themes())),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text("Open EduServe"),
                onPressed: () async {
                  await launch(eduserveURL);
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text("Update credentials"),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => Credentials()));
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  child: Text("Check updates"),
                  onPressed: () async {
                    PackageInfo info = await PackageInfo.fromPlatform();
                    if (info.packageName.contains("dev") ||
                        info.packageName.contains("stg"))
                      Fluttertoast.showToast(
                          msg: "You are running a non-production build!");

                    final newVersion = NewVersion(androidId: info.packageName);
                    newVersion.showAlertIfNecessary(context: context);
                    bool? canUpdate =
                        (await newVersion.getVersionStatus())?.canUpdate;
                    if (canUpdate ?? false)
                      Fluttertoast.showToast(
                          msg: "You are already on latest version!");
                    // launch(
                    //     "https://github.com/hiruthic2002/eduserveMinimal/releases");
                  }),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  child: Text("Attributions"),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AttributionScreen()))),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  child: Text("Manage Cache Data"),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CacheDataView()))),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      child: Text("About"),
                      onPressed: () async {
                        PackageInfo info = await PackageInfo.fromPlatform();

                        showAboutDialog(
                            context: context,
                            applicationVersion: info.version,
                            applicationLegalese: "Yo, nice!");
                      }),
                ),
                Spacer(),
                Expanded(
                  child: ElevatedButton(
                    child: Text("Author"),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Developer()));
                    },
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Text("♥️"),
                ),
                GestureDetector(
                  child: Text("Contribute",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue)),
                  onTap: () =>
                      launch("https://github.com/hiruthic2002/eduserveMinimal"),
                ),
                Text(" to this project"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
