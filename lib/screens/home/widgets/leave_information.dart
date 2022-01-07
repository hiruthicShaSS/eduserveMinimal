// Flutter imports:
import 'package:eduserveMinimal/models/leave.dart';
import 'package:eduserveMinimal/service/leave_info.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/screens/home/widgets/leave_list.dart';
import 'package:eduserveMinimal/screens/home/widgets/on_duty_list.dart';

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
    // Provider.of<AppState>(context, listen: false).scraper.getLeaveInfo();
    // return Container();

    Leave fakeLeaveData = Leave.generateFakeLeave();

    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: "Leave",
              ),
              Tab(
                text: "On-Duty Details",
              ),
            ],
            labelColor:
                ThemeProvider.currentThemeData!.textTheme.bodyText1!.color,
          ),
          Expanded(
            child: FutureBuilder(
              future: getLeaveInfo(),
              builder: (context,
                  AsyncSnapshot<Leave> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Provider.of<AppState>(context, listen: false).leaveInfo =
                      snapshot.data;

                  if (snapshot.data == null)
                    return Text("No records to display.");

                  List<OtherLeave>? leave = snapshot.data?.allLeave;
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
                    LeaveList(leave: fakeLeaveData.allLeave, isLoading: true),
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
