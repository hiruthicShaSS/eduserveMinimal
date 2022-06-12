// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/providers/theme.dart';

class ApplyLeaveView extends StatefulWidget {
  const ApplyLeaveView({Key? key, this.leaveType = LeaveType.Medical})
      : super(key: key);

  final LeaveType leaveType;

  @override
  State<ApplyLeaveView> createState() => _ApplyLeaveViewState();
}

class _ApplyLeaveViewState extends State<ApplyLeaveView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.index = widget.leaveType == LeaveType.Medical ? 0 : 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Apply Leave"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Consumer(builder: (_, ThemeProvider themeProvider, __) {
              return TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: "Medical"),
                  Tab(text: "OnDuty"),
                ],
                labelColor:
                    themeProvider.currentThemeData.textTheme.bodyText1!.color,
              );
            }),
            Expanded(
              child: TabBarView(controller: _tabController, children: [
                MedicalLeaveWidget(),
                OnDutyLeaveWidget(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalLeaveWidget extends StatelessWidget {
  const MedicalLeaveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Medical"),
    );
  }
}

class OnDutyLeaveWidget extends StatelessWidget {
  const OnDutyLeaveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("On Duty"),
    );
  }
}
