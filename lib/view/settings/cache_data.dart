// 🐦 Flutter imports:
import 'package:eduserveMinimal/global/constants.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheDataView extends StatelessWidget {
  CacheDataView({Key? key}) : super(key: key);

  late final SharedPreferences _prefs;
  late final FlutterSecureStorage _storage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getLocalStorageInstances(),
          builder: (context, snapshot) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            await _prefs.remove(prefs_key_timeTableLastUpdate);
                            await _storage.delete(
                                key: storage_key_timetableData);

                            Fluttertoast.showToast(
                                msg: "Timetable data resetted!");
                          },
                          child: Text("Reset Timtable Data")),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            await _prefs.remove(prefs_key_userLastUpdate);
                            await _storage.delete(key: storage_key_userData);
                            Fluttertoast.showToast(msg: "User data resetted!");
                          },
                          child: Text("Reset User Data")),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  getLocalStorageInstances() async {
    _prefs = await SharedPreferences.getInstance();
    _storage = FlutterSecureStorage();
  }
}
