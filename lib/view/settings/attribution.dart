// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:url_launcher/url_launcher.dart';

class AttributionScreen extends StatelessWidget {
  const AttributionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Attribution> attributions = [
      Attribution(
          AttributionType.Animation,
          "Alex Martov",
          "https://lottiefiles.com/8654-unlocked",
          "Lottie Files",
          "https://lottiefiles.com"),
      Attribution(
          AttributionType.Animation,
          "Emas Didik Prasetyo",
          "https://lottiefiles.com/73194-happy-birthday",
          "Lottie Files",
          "https://lottiefiles.com"),
      Attribution(
          AttributionType.Animation,
          "Sammie Ho",
          "https://lottiefiles.com/62717-confetti",
          "Lottie Files",
          "https://lottiefiles.com"),
      Attribution(
          AttributionType.Animation,
          "Shlomi Platzman",
          "https://lottiefiles.com/24586-gifts-open",
          "Lottie Files",
          "https://lottiefiles.com"),
      Attribution(
          AttributionType.Animation,
          "VersaStock",
          "https://lottiefiles.com/41070-notepad-with-a-list-of-tick-boxes-and-5-star-feedback",
          "Lottie Files",
          "https://lottiefiles.com"),
      Attribution(
          AttributionType.Image,
          "unDraw",
          "https://lottiefiles.com/41070-notepad-with-a-list-of-tick-boxes-and-5-star-feedback",
          "unDraw",
          "https://undraw.co"),
      Attribution(
          AttributionType.Image,
          "unDraw",
          "https://lottiefiles.com/41070-notepad-with-a-list-of-tick-boxes-and-5-star-feedback",
          "unDraw",
          "https://undraw.co"),
      Attribution(
          AttributionType.GIF,
          "Valorant",
          "https://giphy.com/gifs/playvalorant-transparent-GuX4wXQnebwakfBRHE",
          "GIPHY",
          "https://giphy.com/"),
      Attribution(
          AttributionType.GIF,
          "Valorant",
          "https://giphy.com/gifs/kj-valorant-killjoy-JKwo7P9nu7vINc879r",
          "GIPHY",
          "https://giphy.com/"),
      Attribution(
          AttributionType.GIF,
          "Valorant",
          "https://giphy.com/gifs/playvalorant-valorant-skye-trailblazer-yu6tnbAPwZOlFDWSgY",
          "GIPHY",
          "https://giphy.com/"),
      Attribution(
          AttributionType.GIF,
          "Valorant",
          "https://giphy.com/gifs/playvalorant-eye-blind-leer-gxboUsrwPQ1Pmt01IH",
          "GIPHY",
          "https://giphy.com/"),
      Attribution(
          AttributionType.GIF,
          "Valorant",
          "https://giphy.com/gifs/playvalorant-transparent-tqKpvAu2ea9KJhpyp6",
          "GIPHY",
          "https://giphy.com/"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Attributions"),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: attributions.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(10),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
                children: [
                  TextSpan(
                    text: describeEnum(attributions[index].type),
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => launchUrl(Uri.parse(attributions[index].url)),
                  ),
                  TextSpan(text: " from "),
                  TextSpan(text: attributions[index].author),
                  TextSpan(text: " by "),
                  TextSpan(
                    text: attributions[index].source,
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          launchUrl(Uri.parse(attributions[index].sourceUrl)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AttributionType { Image, Animation, GIF }

class Attribution {
  final AttributionType type;
  final String author;
  final String url;
  final String source;
  final String sourceUrl;

  Attribution(this.type, this.author, this.url, this.source, this.sourceUrl);
}
