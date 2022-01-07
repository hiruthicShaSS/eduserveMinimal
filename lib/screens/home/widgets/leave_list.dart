// Flutter imports:
import 'package:eduserveMinimal/models/leave.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/screens/home/pages/apply_leave.dart';

class LeaveList extends StatelessWidget {
  const LeaveList({Key? key, required this.leave, this.isLoading = false})
      : super(key: key);
  final List<OtherLeave>? leave;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: leave!.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0)
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.add),
                    label: Text("Apply leave"),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                ApplyLeaveView(leaveType: LeaveType.Medical))),
                  ),
                ],
              );

            if (isLoading)
              return Shimmer.fromColors(
                child: leaveTile(context, 1),
                baseColor: Colors.grey,
                highlightColor: Colors.grey[900]!,
              );
            return leaveTile(context, index);
          },
        ),
      ),
    );
  }

  Padding leaveTile(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .color!
                  .withOpacity(0.2),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    leave![index - 1].reason.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .withOpacity(0.3)),
                  ),
                  Text(
                    "${leave![index - 1].fromDate} - ${leave![index - 1].toDate}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    leave![index - 1].session,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: leave![index - 1].status.contains("Active")
                        ? Colors.greenAccent.withOpacity(0.8)
                        : leave![index - 1].status.contains("Rejected")
                            ? Colors.redAccent.withOpacity(0.8)
                            : Colors.orangeAccent.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    leave![index - 1].status,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 15),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.transparent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.chevron_right),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: Text(leave![index - 1].reason.toString()),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Duration: ${leave![index - 1].fromDate} - ${leave![index - 1].fromDate}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text("From Session: ${leave![index - 1].fromSession}"),
                                  Text("To Session: ${leave![index - 1].toSession}"),
                                  Text("Status: ${leave![index - 1].status}"),
                                  SizedBox(height: 10),
                                  Center(
                                    child: TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text("Close")),
                                  ),
                                ],
                              ),
                            ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
