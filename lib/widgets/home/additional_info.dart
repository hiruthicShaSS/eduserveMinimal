// Flutter imports:
import 'package:flutter/material.dart';

class AdditionalInfo extends StatelessWidget {
  const AdditionalInfo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container();
        }
        return LinearProgressIndicator();
      },
    );
  }
}
