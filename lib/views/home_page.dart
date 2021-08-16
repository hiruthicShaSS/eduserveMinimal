import 'package:eduserveMinimal/widgets/home/additional_info.dart';
import 'package:eduserveMinimal/widgets/home/attendance_widget.dart';
import 'package:eduserveMinimal/widgets/home/leave_information.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AttendanceContainer(),
        LeaveInformation(),
      ],
    );
  }
}
