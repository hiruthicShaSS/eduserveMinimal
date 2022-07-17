// 🐦 Flutter imports:
import 'dart:developer';

import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/models/leave/leave.dart';
import 'package:eduserveMinimal/models/leave/on_duty_leave.dart';
import 'package:eduserveMinimal/models/leave/other_leave.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/view/home/leaves/widgets/leave_list.dart';
import 'package:eduserveMinimal/view/home/leaves/widgets/on_duty_list.dart';
import 'package:eduserveMinimal/view/misc/widgets/dot_tab_bar_indeicator.dart';

class LeaveInformation extends StatefulWidget {
  const LeaveInformation({Key? key}) : super(key: key);

  @override
  _LeaveInformationState createState() => _LeaveInformationState();
}

class _LeaveInformationState extends State<LeaveInformation>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Leave fakeLeaveData = Leave.generateFakeLeave();

    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      child: Column(
        children: [
          Consumer(builder: (_, ThemeProvider themeProvider, __) {
            return TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: "Leave"),
                Tab(text: "On-Duty Details"),
              ],
              indicator: CircleTabIndicator(
                  color: Theme.of(context).primaryColor, radius: 5),
              labelColor:
                  themeProvider.currentThemeData.textTheme.bodyText1!.color,
              overlayColor: MaterialStateProperty.resolveWith(
                  (states) => Colors.transparent),
            );
          }),
          Expanded(
            child: FutureBuilder(
              future: Provider.of<AppState>(context).getLeaveInformation(),
              builder: (context, AsyncSnapshot<Leave> snapshot) {
                if (snapshot.hasError) {
                  log("", error: snapshot.error);
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null)
                    return Text("No records to display.");

                  Provider.of<AppState>(context).setLeave = snapshot.data!;

                  List<OtherLeave>? leave = snapshot.data?.allNormalLeave;
                  List<OnDutyLeave>? onDuty = snapshot.data?.allOnDuty;

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      LeaveList(leave: leave),
                      OnDutyList(leave: onDuty),
                    ],
                  );
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    LeaveList(
                        leave: fakeLeaveData.allNormalLeave, isLoading: true),
                    OnDutyList(leave: fakeLeaveData.allOnDuty, isLoading: true),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
