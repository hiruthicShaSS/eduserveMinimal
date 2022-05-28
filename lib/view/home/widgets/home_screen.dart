import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:eduserveMinimal/view/home/leaves/leave_information.dart';
import 'package:eduserveMinimal/view/home/widgets/attendance_summary_basic.dart';
import 'package:eduserveMinimal/view/home/widgets/attendance_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: 100,
      onRefresh: () => AuthService().login().then((value) {
        Scraper.cache.clear();
        Provider.of<AppState>(context, listen: false).refresh();
      }),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.25,
            title: Text("eduserveMinimal"),
            pinned: true,
            snap: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * (0.25 * 0.46)),
                child: AttendanceContainer(),
              ),
              stretchModes: [
                StretchMode.blurBackground,
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            )),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              LeaveInformationWidget(),
              AttendanceSummaryWidget(),
            ]),
          ),
        ],
      ),
    );
  }
}
