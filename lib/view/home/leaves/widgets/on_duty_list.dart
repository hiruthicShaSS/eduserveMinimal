// 🐦 Flutter imports:
import 'package:eduserveMinimal/models/leave/on_duty_leave.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shimmer/shimmer.dart';

class OnDutyList extends StatelessWidget {
  const OnDutyList({Key? key, required this.leave, this.isLoading = false})
      : super(key: key);
  final List<OnDutyLeave>? leave;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: leave!.length,
          itemBuilder: (BuildContext context, int index) {
            if (isLoading)
              return Shimmer.fromColors(
                child: onDutyTile(context, 1),
                baseColor: Colors.grey,
                highlightColor: Colors.grey[900]!,
              );
            return onDutyTile(context, index);
          },
        ),
      ),
    );
  }

  Padding onDutyTile(BuildContext context, int index) {
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
                    leave![index].reason.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .withOpacity(0.3)),
                  ),
                  Text(
                    "${leave![index].fromDate} - ${leave![index].toDate}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    leave![index].session,
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
                    color: leave![index].status.contains("AVAILED")
                        ? Colors.greenAccent.withOpacity(0.8)
                        : leave![index].status.contains("REJECTED")
                            ? Colors.redAccent.withOpacity(0.8)
                            : Colors.orangeAccent.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    leave![index].status,
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
                              title: Text(leave![index].reason.toString()),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Duration: ${leave![index].fromDate} - ${leave![index].toDate}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                      "Created on: ${leave![index].createdOn.toString()}"),
                                  Text(
                                      "From Session: ${leave![index].fromSession}"),
                                  Text(
                                      "To Session: ${leave![index].toSession}"),
                                  Text("Status: ${leave![index].status}"),
                                  SizedBox(height: 10),
                                  Text(
                                      "Created by: ${leave![index].createdBy}"),
                                  Text(
                                      "Approval by: ${leave![index].approvalBy}"),
                                  Text(
                                      "Approval on: ${leave![index].approvalOn}"),
                                  Text(
                                      "Availed by: ${leave![index].availedBy}"),
                                  Text(
                                      "Availed on: ${leave![index].availedOn}"),
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
