// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/app_state.dart';

class User extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<AppState>(context).scraper.getInfo(),
        builder: (context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print(snapshot.data);
            Map data = snapshot.data!;

            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.0),
                      Center(
                        child: Hero(
                          tag: "hero-userImage",
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: AssetImage("assets/appIcon.png"),
                            backgroundColor: Colors.transparent,
                            onBackgroundImageError: (_, __) =>
                                Image.asset("assets/placeholder_profile.png"),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              MainContainer(title: "CGPA", data: data["cgpa"]),
                              MainContainer(title: "SGPA", data: data["sgpa"]),
                              MainContainer(
                                  title: "CREDITS", data: data["credits"]),
                            ],
                          ),
                        ),
                      ),
                      UserDetailWidget(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['reg'], style: TextStyle(fontSize: 30)),
                            Text(data['name'], style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                      UserDetailWidget(
                          child: Text(
                        data['programme'],
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
                                  data['kmail'],
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  data['mobile'],
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                            IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          "${data["kmail"]}\n${data["mobile"]}"));
                                  Fluttertoast.showToast(
                                      msg: "Copied to clipboard");
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
                                  "Non Academic Credits : ${data['nonAcademicCredits']}",
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  "Mentor : ${data['mentor']}",
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  "Arrears : ${data['arrears']}",
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  "Semester : ${data['semester']}",
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  "Above data represented here are result of ${data['resultOf']}",
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}

class UserDetailWidget extends StatelessWidget {
  const UserDetailWidget({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
      child: Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }
}

class MainContainer extends StatelessWidget {
  const MainContainer({
    Key? key,
    required this.title,
    required this.data,
  }) : super(key: key);

  final String title;
  final String? data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(20),
        width: 120,
        decoration: BoxDecoration(
          color: Colors.transparent.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text(data!),
          ],
        ),
      ),
    );
  }
}
