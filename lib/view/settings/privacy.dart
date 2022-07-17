import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/constants.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _attachRegisterNumberToCrashLogs = false;
  bool _attachKmailToCrash = false;
  bool _attachNameToCrash = false;

  @override
  void didChangeDependencies() {
    setupDefaults();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              ExpansionTile(
                key: PageStorageKey(DateTime.now().millisecondsSinceEpoch),
                onExpansionChanged: updatePersonalDataAttachementToCrash,
                initiallyExpanded: _attachRegisterNumberToCrashLogs,
                maintainState: true,
                trailing: IgnorePointer(
                  child: Switch(
                    value: _attachRegisterNumberToCrashLogs,
                    onChanged: (_) {},
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Attach personal data to crash logs"),
                  ],
                ),
                childrenPadding: const EdgeInsets.all(10),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Attach register number"),
                      Switch(value: true, onChanged: null),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Attach kmail"),
                      Switch(
                          value: _attachKmailToCrash,
                          onChanged: (value) async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            await prefs.setBool(kAttachKmailToCrashLogs, value);
                            setState(() {
                              _attachKmailToCrash = value;
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Attach name"),
                      Switch(
                          value: _attachNameToCrash,
                          onChanged: (value) async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            await prefs.setBool(kAttachNameToCrashLogs, value);
                            setState(() {
                              _attachNameToCrash = value;
                            });
                          }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  setupDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _attachRegisterNumberToCrashLogs =
          prefs.getBool(kAttachRegisterNumberToCrashLogs) ?? false;
      _attachKmailToCrash = prefs.getBool(kAttachKmailToCrashLogs) ?? false;
      _attachNameToCrash = prefs.getBool(kAttachNameToCrashLogs) ?? false;
    });
  }

  Future<void> updatePersonalDataAttachementToCrash(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(kAttachRegisterNumberToCrashLogs, value);

    setState(() {
      _attachRegisterNumberToCrashLogs = value;
    });

    Fluttertoast.showToast(
      msg:
          "Your next crash logs will be sent ${value ? "with" : "without"} your registration number attached!",
      backgroundColor: value ? Colors.green : null,
    );
  }
}
