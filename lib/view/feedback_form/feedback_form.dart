// 🐦 Flutter imports:
import 'dart:developer';

import 'package:eduserveMinimal/models/feedback_entry.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/fill_feedback_form.dart';
import 'package:eduserveMinimal/service/get_feedback_form.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeedbackForm extends StatefulWidget {
  FeedbackForm({Key? key}) : super(key: key);

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  Map feedbackRating = {};

  late Future<List<FeedbackEntry>> _getFeedBackFuture;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _getFeedBackFuture = getFeedbackForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hourly Feedback")),
      body: WebView(
        initialUrl: "https://eduserve.karunya.edu/Login.aspx",
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onPageFinished: (url) async {
          if (url == "https://eduserve.karunya.edu/Login.aspx") {
            final FlutterSecureStorage storage = FlutterSecureStorage();

            String username = (await storage.read(key: "username"))!;
            String password = (await storage.read(key: "password"))!;
            _webViewController.runJavascript(
                'document.getElementById("mainContent_Login1_UserName").value="${username}";document.getElementById("mainContent_Login1_Password").value="${password}";document.getElementById("mainContent_Login1_LoginButton").click();');
          } else if (url == "https://eduserve.karunya.edu/Student/Home.aspx") {
            Navigator.of(context).pushReplacementNamed("/home");
          }
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Hourly Feedback")),
      body: FutureBuilder<List<FeedbackEntry>>(
        future: _getFeedBackFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            log("", error: snapshot.error);
          }

          if (snapshot.connectionState == ConnectionState.done) {
            List<FeedbackEntry>? data = snapshot.data;

            if (data == null) return Text("Something went wrong");

            return ListView(
              children: List.generate(snapshot.data!.length + 1, (index) {
                if (index == snapshot.data!.length)
                  return ElevatedButton(
                    onPressed: () async {
                      bool feedBackFormFilled =
                          await fillFeedbackForm(feedbackRating);
                      if (feedBackFormFilled) {
                        Navigator.of(context).pushNamed("/home");
                        return;
                      }

                      Fluttertoast.showToast(msg: "Something went wrong!");
                    },
                    child: Text("Submit"),
                  );

                feedbackRating[data[index].htmlId] = 1;

                return ExpansionTile(
                  title: Text(data[index].subject),
                  subtitle: data[index].hour == "Lab"
                      ? Text("Lab")
                      : Text("Hour ${data[index].hour}"),
                  children: [
                    RatingBar.builder(
                      initialRating: 1,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      glow: false,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        feedbackRating[data[index].htmlId] = rating.toInt();
                      },
                    )
                  ],
                );
              }),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Getting feedback form..."),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }
}
