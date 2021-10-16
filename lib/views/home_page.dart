// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:eduserveMinimal/widgets/home/attendance_widget.dart';
import 'package:eduserveMinimal/widgets/home/leave_information.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
