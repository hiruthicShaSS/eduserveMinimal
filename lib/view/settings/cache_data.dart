// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 📦 Package imports:
import 'package:fluttertoast/fluttertoast.dart';

class CacheDataView extends StatelessWidget {
  const CacheDataView({Key? key}) : super(key: key);

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
                      final FlutterSecureStorage storage =
                          FlutterSecureStorage();

                      await storage.delete(key: "timetable");
                      Fluttertoast.showToast(msg: "Timetable data resetted!");
                    },
                    child: Text("Reset Timtable Data")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
