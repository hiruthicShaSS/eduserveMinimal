// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
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
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Attributions"),
      ),
      body: SafeArea(
        child: ListView.builder(
            itemCount: attributions.length,
            itemBuilder: (context, index) => Row(
                  children: [
                    TextButton(
                      onPressed: () => launch(attributions[index].url),
                      child: Text(
                        describeEnum(attributions[index].type),
                      ),
                    ),
                    Text("from "),
                    Text(attributions[index].author),
                    Text(" by"),
                    TextButton(
                        onPressed: () => launch(attributions[index].sourceUrl),
                        child: Text(attributions[index].source)),
                  ],
                )),
      ),
    );
  }
}

enum AttributionType { Image, Animation }

class Attribution {
  final AttributionType type;
  final String author;
  final String url;
  final String source;
  final String sourceUrl;

  Attribution(this.type, this.author, this.url, this.source, this.sourceUrl);
}
