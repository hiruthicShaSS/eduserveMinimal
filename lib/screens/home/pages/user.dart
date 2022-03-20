import 'package:eduserveMinimal/models/user.dart';
import 'package:eduserveMinimal/screens/home/widgets/semester_summary_widget.dart';
import 'package:eduserveMinimal/screens/settings/widgets/user_detail.dart';
import 'package:eduserveMinimal/screens/settings/widgets/user_header.dart';
import 'package:eduserveMinimal/screens/settings/widgets/user_main_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:fluttertoast/fluttertoast.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/student_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
            future: getInfo(),
            builder: (context, AsyncSnapshot<User> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                User user = snapshot.data!;

                return _MainScreen(user: user, cached: false);
              }

              return FutureBuilder(
                future: SharedPreferences.getInstance(),
                builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data!.containsKey("userData")) {
                    User user =
                        User.fromJson(snapshot.data!.getString("userData")!);

                    return _MainScreen(user: user);
                  }

                  return Center(child: CircularProgressIndicator());
                },
              );
            }),
      ),
    );
  }
}

class _MainScreen extends StatelessWidget {
  const _MainScreen({
    Key? key,
    required this.user,
    this.cached = true,
  }) : super(key: key);

  final User user;
  final bool cached;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (cached)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            child: Center(
                child: Text(
                    "Viewing cached data!. Wait for the page to update...")),
          ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                UserHeader(
                  studentImg: user.image,
                  qrCode: user.qrCode,
                  reg: user.registerNumber,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        MainContainer(
                            title: "Arrears",
                            data: user.arrears.toString(),
                            color: user.arrears > 0 ? Colors.red : null),
                        MainContainer(
                            title: "CGPA", data: user.cgpa.toString()),
                        MainContainer(
                            title: "SGPA", data: user.sgpa.toString()),
                        MainContainer(
                            title: "CREDITS", data: user.credits.toString()),
                      ],
                    ),
                  ),
                ),
                UserDetailWidget(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.registerNumber ?? "",
                          style: TextStyle(fontSize: 30)),
                      Text(user.name ?? "A Karunya",
                          style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
                UserDetailWidget(
                    child: Text(
                  user.programme ?? "",
                  style: TextStyle(fontSize: 17),
                )),
                UserDetailWidget(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.kmail ?? "someone@karunya.edu.in",
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            user.mobile ?? "",
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: "${user.kmail}\n${user.mobile}"));
                            Fluttertoast.showToast(msg: "Copied to clipboard");
                          },
                          icon: Icon(Icons.copy)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 20),
                      child: Text("Misc", style: TextStyle(fontSize: 25)),
                    ),
                    UserDetailWidget(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Non Academic Credits : ${user.nonAcademicCredits}",
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            "Mentor : ${user.mentor}",
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            "Semester : ${user.semester}",
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            "Above data represented here are result of ${user.resultOf}",
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SemesterSummaryWidget(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
