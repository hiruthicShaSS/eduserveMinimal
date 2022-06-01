// 🐦 Flutter imports:
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/view/settings/cache_data.dart';
import 'package:eduserveMinimal/view/settings/credentials.dart';
import 'package:eduserveMinimal/view/settings/attribution.dart';
import 'package:eduserveMinimal/view/settings/developer.dart';
import 'package:eduserveMinimal/view/settings/themes.dart';

class Settings extends StatelessWidget {
  static final thisAppPublishDate = "2020-12-20 19:38:07.569667";
  final String eduserveURL =
      "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2f";
  bool _isLogOutClicked = false;

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
                onPressed: () {
                  Navigator.of(context).pushNamed("/notifications");
                },
                child: Text("Notifications"),
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
                        info.packageName.contains("stg")) {
                      Fluttertoast.showToast(
                          msg: "You are running a non-production build!");

                      return;
                    }

                    final newVersion = NewVersion(androidId: info.packageName);
                    newVersion.showAlertIfNecessary(context: context);

                    bool? canUpdate =
                        (await newVersion.getVersionStatus())?.canUpdate;

                    if (canUpdate ?? false) {
                      Fluttertoast.showToast(
                          msg: "You are already on latest version!");
                    }
                  }),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  child: Text("Manage Cache Data"),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CacheDataView()))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: ElevatedButton(
                        child: Text("Attribution"),
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => AttributionScreen()))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ElevatedButton(
                      child: Text("Author"),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Developer()));
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout),
                onPressed: () =>
                    Fluttertoast.showToast(msg: "Press and hold for action"),
                onLongPress: () async {
                  AppTheme appTheme =
                      Provider.of<ThemeProvider>(context, listen: false)
                          .currentAppTheme;

                  showDialog(
                    context: context,
                    builder: (_) => StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: appTheme == AppTheme.valorant
                              ? null
                              : Text("Logout"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (appTheme == AppTheme.valorant)
                                Image.asset("assets/images/danger.gif"),
                              Text("Are you sure you want to logout?"),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                setState(() => _isLogOutClicked = true);

                                await AuthService().logout();

                                Fluttertoast.showToast(msg: "Logout completed");
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    "/credentials", (route) => false);
                              },
                              child: _isLogOutClicked
                                  ? SizedBox(
                                      width: 80,
                                      child: LinearProgressIndicator())
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
                      },
                    ),
                  );
                },
                label: Text("Logout"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => Colors.red),
                ),
              ),
            ),
            Spacer(),
            Column(
              children: [
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
                      onTap: () => launchUrl(Uri.parse(
                          "https://github.com/hiruthicShaSS/eduserveMinimal")),
                    ),
                    Text(" to this project"),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Text("⭐"),
                    ),
                    GestureDetector(
                      child: Text("Post a review",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      onTap: () async {
                        final InAppReview inAppReview = InAppReview.instance;

                        if (await inAppReview.isAvailable()) {
                          inAppReview.requestReview();
                        }
                      },
                    ),
                    Text(" for this project"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
