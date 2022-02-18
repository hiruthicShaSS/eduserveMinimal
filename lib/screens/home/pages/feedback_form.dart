// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/fill_feedback_form.dart';
import 'package:eduserveMinimal/service/get_feedback_form.dart';

class FeedbackForm extends StatefulWidget {
  FeedbackForm({Key? key}) : super(key: key);

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  Map feedbackRating = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFeedbackForm(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView(
            children: List.generate(snapshot.data!.length + 2, (index) {
              if (index == 0)
                return Column(
                  children: [
                    Center(
                        child: Text("Hourly Feedback",
                            style: TextStyle(fontSize: 30))),
                    Divider(),
                  ],
                );
              if (index == snapshot.data!.length + 1)
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

              feedbackRating[snapshot.data![index - 1].last.toString()] = 1;

              return ExpansionTile(
                title: Text(snapshot.data![index - 1][1].toString()),
                subtitle:
                    Text("Hour ${snapshot.data![index - 1][0].toString()}"),
                children: [
                  RatingBar.builder(
                    initialRating: 1,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      feedbackRating[snapshot.data![index - 1].last
                          .toString()] = rating.toInt();
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
    );
  }
}
