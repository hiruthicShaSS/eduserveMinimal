import 'package:eduserveMinimal/views/fees.dart';
import 'package:eduserveMinimal/views/hallticket.dart';
import 'package:flutter/material.dart';

class IssuesView extends StatelessWidget {
  const IssuesView(
      {Key? key,
      required this.outstandingDue,
      required this.hallTicketUnEligible})
      : super(key: key);

  final bool outstandingDue;
  final bool hallTicketUnEligible;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Issues"),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: Text("Issues Feature"),
                          content: Text(
                              "Issues page will suggest potential issues you might experience by the data provided in eduserve. This feature will suggest issues by statically analysing the data and not by any intelligent models."),
                        ));
              },
              icon: Icon(Icons.info_outline))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Visibility(
              visible: outstandingDue,
              child: ListTile(
                tileColor: Colors.redAccent.withOpacity(0.6),
                title: Text("You have outstanding fees due"),
                trailing: TextButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => FeesView())),
                  child: Text("Review"),
                ),
              ),
            ),
            Visibility(
              visible: hallTicketUnEligible,
              child: ListTile(
                tileColor: Colors.orangeAccent.withOpacity(0.6),
                title: Text("You might have issues on hallticket download"),
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => HallTicketView())),
                  child: Text("Review"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
