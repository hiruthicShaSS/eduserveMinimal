// 🐦 Flutter imports:
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/models/leave.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/screens/home/widgets/dot_tab_bar_indeicator.dart';
import 'package:eduserveMinimal/screens/home/widgets/leave_list.dart';
import 'package:eduserveMinimal/screens/home/widgets/on_duty_list.dart';
import 'package:eduserveMinimal/service/leave_info.dart';
import 'package:provider/provider.dart';

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
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Leave"),
              Tab(text: "On-Duty Details"),
            ],
            indicator: CircleTabIndicator(
                color: Theme.of(context).primaryColor, radius: 5),
            labelColor:
                ThemeProvider.currentThemeData!.textTheme.bodyText1!.color,
            overlayColor: MaterialStateProperty.resolveWith(
                (states) => Colors.transparent),
          ),
          Expanded(
            child: FutureBuilder(
              future: getLeaveInfo(),
              builder: (context, AsyncSnapshot<Leave> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    print(snapshot);
                  }

                  if (snapshot.data == null)
                    return Text("No records to display.");

                  Provider.of<AppState>(context).leave = snapshot.data!;

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
