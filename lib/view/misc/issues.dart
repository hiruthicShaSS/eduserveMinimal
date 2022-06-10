// 🐦 Flutter imports:
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/providers/issue_provider.dart';
import 'package:eduserveMinimal/view/home/semester_attendance_view.dart';
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/view/fees/fees.dart';
import 'package:eduserveMinimal/view/home/hallticket.dart';
import 'package:provider/provider.dart';

class IssuesView extends StatelessWidget {
  const IssuesView({Key? key}) : super(key: key);

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
        child: Consumer(builder: (context, IssueProvider issueProvider, _) {
          return Column(
            children: [
              Visibility(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed:
                        issueProvider.isEmpty ? null : issueProvider.clear,
                    icon: Icon(Icons.clear_all),
                    label: Text("Mark All As Read"),
                  ),
                ),
              ),
              Visibility(
                visible: issueProvider.issues.contains(Issue.fees_due),
                child: Dismissible(
                  key: Key(Issue.fees_due.toString()),
                  onDismissed: (direction) {
                    issueProvider.remove(Issue.fees_due);
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text("You have outstanding fees due"),
                    trailing: TextButton(
                      onPressed: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => FeesView())),
                      child: Text("Review"),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible:
                    issueProvider.issues.contains(Issue.hallticket_ineligible),
                child: Dismissible(
                  key: Key(Issue.hallticket_ineligible.toString()),
                  onDismissed: (direction) {
                    issueProvider.remove(Issue.hallticket_ineligible);
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text("You might have issues on hallticket download"),
                    trailing: TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => HallTicketView())),
                      child: Text("Review"),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: issueProvider.issues.contains(Issue.abesnt_yesterday),
                child: Dismissible(
                  key: Key(Issue.abesnt_yesterday.toString()),
                  onDismissed: (direction) {
                    issueProvider.remove(Issue.abesnt_yesterday);
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text("You were marked absent for certain classes"),
                    trailing: TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => SemesterAttendanceView())),
                      child: Text("Review"),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
