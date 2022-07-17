// 🐦 Flutter imports:
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheDataView extends StatelessWidget {
  CacheDataView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      await Provider.of<AppState>(context, listen: false)
                          .resetTimeTable();

                      Fluttertoast.showToast(msg: "Timetable data resetted!");
                    },
                    child: Text("Reset Timetable Data")),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      await Provider.of<AppState>(context, listen: false)
                          .resetUser();

                      Fluttertoast.showToast(msg: "User data resetted!");
                    },
                    child: Text("Reset User Data")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
