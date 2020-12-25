import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:eduserveMinimal/themes/themes.dart';

class Settings extends StatelessWidget {
  static final thisAppPublishDate = "2020-12-20 19:38:07.569667";
  final String eduserveURL =
      "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2f";
  final Shader linearGradient = LinearGradient(
    colors: <Color>[
      HexColor("#eeaeca"),
      HexColor("#94bbe9"),
    ],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

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
              child: Text("Update credentials"),
              onPressed: () {
                Navigator.pushNamed(context, "/updateCreds");
              },
            ),
            RaisedButton(
                child: Text("Check updates"),
                onPressed: () async {
                  if (await canLaunch(
                      "https://github.com/hiruthic2002/eduserveMinimal/releases")) {
                    launch(
                        "https://github.com/hiruthic2002/eduserveMinimal/releases");
                  }
                }),
            RaisedButton(
              child: Text("About"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return buildAboutPage();
                }));
              },
            )
          ],
        ),
      ),
    );
  }

  Scaffold buildAboutPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Center(
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(
                        "https://avatars1.githubusercontent.com/u/56349092?s=400&u=bd905296ec34d032c6c6d87f5b89e0f7dc5f0956&v=4"),
                    backgroundColor: Colors.transparent,
                    onBackgroundImageError: (_, __) {
                      return Image.asset("assets/placeholder_profile.png");
                    },
                  ),
                ),
              ),
              Spacer(),
              Text(
                "hiruthicSha",
                style: GoogleFonts.kanit(
                  fontSize: 30,
                  foreground: Paint()..shader = linearGradient,
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.email),
                    onPressed: () async {
                      if (await canLaunch("mailto:hiruthic@karunya.edu")) {
                        launch("mailto:hiruthic@karunya.edu");
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  Text(
                    "hiruthic@karunya.edu.in",
                    style: GoogleFonts.kanit(
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
              Spacer(),
              RaisedButton(
                color: Colors.amberAccent,
                splashColor: Colors.amber,
                child: Text(
                  "Request Feature",
                  style: GoogleFonts.kanit(fontSize: 25, color: Colors.black),
                ),
                onPressed: () async {
                  if (await canLaunch(
                      "https://github.com/hiruthic2002/eduserveMinimal/issues/new")) {
                    launch(
                        "https://github.com/hiruthic2002/eduserveMinimal/issues/new");
                  }
                },
              ),
              Spacer(),
              buildSocialIcons()
            ],
          ),
        ),
      ),
    );
  }

  Row buildSocialIcons() {
    return Row(
      children: [
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.instagram,
            size: 40,
            color: Colors.red,
          ),
          onPressed: () async {
            if (await canLaunch("https://www.instagram.com/hiruthicSha/")) {
              launch("https://www.instagram.com/hiruthicSha/");
            } else {
              Fluttertoast.showToast(msg: "Cant open Instagram at the moment");
            }
          },
          tooltip: "Instagram",
        ),
        Spacer(),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.twitter,
            size: 40,
            color: Colors.blue,
          ),
          onPressed: () async {
            if (await canLaunch("https://twitter.com/Hiruthic1")) {
              launch("https://twitter.com/Hiruthic1");
            } else {
              Fluttertoast.showToast(msg: "Cant open Twitter at the moment");
            }
          },
          tooltip: "Twitter",
        ),
        Spacer(),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.linkedin,
            size: 40,
            color: Colors.blueAccent,
          ),
          onPressed: () async {
            if (await canLaunch("https://in.linkedin.com/in/hiruthic-s-s")) {
              launch("https://in.linkedin.com/in/hiruthic-s-s/");
            } else {
              Fluttertoast.showToast(msg: "Cant open LinkedIn at the moment");
            }
          },
          tooltip: "LinkedIn",
        ),
        Spacer(),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.github,
            size: 40,
            color: Colors.white38,
          ),
          onPressed: () async {
            if (await canLaunch("https://github.com/hiruthic2002")) {
              launch("https://github.com/hiruthic2002");
            } else {
              Fluttertoast.showToast(msg: "Cant open GitHub at the moment");
            }
          },
          tooltip: "GitHub",
        ),
        Spacer(),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.globe,
            size: 40,
            color: Colors.white38,
          ),
          onPressed: () async {
            if (await canLaunch("http://sha-resume.herokuapp.com/")) {
              launch("http://sha-resume.herokuapp.com/");
            } else {
              Fluttertoast.showToast(msg: "Cant open site at the moment");
            }
          },
          tooltip: "GitHub",
        ),
      ],
    );
  }
}
