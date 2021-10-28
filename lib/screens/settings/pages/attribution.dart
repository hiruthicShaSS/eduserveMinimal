import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Attribution extends StatelessWidget {
  const Attribution({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Attribute> attributions = [
      Attribute(
          AttributeType.Animation,
          "Alex Martov",
          "https://lottiefiles.com/8654-unlocked",
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

enum AttributeType { Image, Animation }

class Attribute {
  final AttributeType type;
  final String author;
  final String url;
  final String source;
  final String sourceUrl;

  Attribute(this.type, this.author, this.url, this.source, this.sourceUrl);
}
