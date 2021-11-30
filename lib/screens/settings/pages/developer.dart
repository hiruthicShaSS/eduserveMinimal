// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Developer extends StatelessWidget {
  Developer({Key? key}) : super(key: key);

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.blueAccent, Colors.lightBlueAccent],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
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
                      Image.asset("assets/placeholder_profile.png");
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
                    onPressed: () => launch("mailto:hiruthic@karunya.edu"),
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.amberAccent,
                ),
                child: Text(
                  "Request Feature",
                  style: GoogleFonts.kanit(fontSize: 25, color: Colors.black),
                ),
                onPressed: () => launch(
                    "https://github.com/hiruthicShaSS/eduserveMinimal/issues/new"),
              ),
              Spacer(),
              buildSocialIcons()
            ],
          ),
        ),
      ),
    );
  }
}

Row buildSocialIcons() {
  return Row(
    children: [
      IconButton(
        icon: FaIcon(
          FontAwesomeIcons.twitter,
          size: 40,
          color: Colors.blue,
        ),
        onPressed: () => launch("https://twitter.com/_hiruthicSha"),
        tooltip: "Twitter",
      ),
      Spacer(),
      IconButton(
        icon: FaIcon(
          FontAwesomeIcons.linkedin,
          size: 40,
          color: Colors.blueAccent,
        ),
        onPressed: () => launch("https://in.linkedin.com/in/hiruthicsha/"),
        tooltip: "LinkedIn",
      ),
      Spacer(),
      IconButton(
        icon: FaIcon(
          FontAwesomeIcons.github,
          size: 40,
          color: Colors.black,
        ),
        onPressed: () => launch("https://github.com/hiruthicShaSS"),
        tooltip: "GitHub",
      ),
      Spacer(),
      IconButton(
        icon: FaIcon(
          FontAwesomeIcons.globe,
          size: 40,
          color: Colors.blueAccent,
        ),
        onPressed: () => launch("http://hiruthicsha.com"),
        tooltip: "GitHub",
      ),
    ],
  );
}
