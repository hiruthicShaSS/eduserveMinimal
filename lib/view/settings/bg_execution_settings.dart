import 'package:eduserveMinimal/global/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/app_state.dart';
import '../../service/bg_service.dart';

class BgExecutionSettings extends StatefulWidget {
  const BgExecutionSettings({Key? key}) : super(key: key);

  @override
  State<BgExecutionSettings> createState() => _BgExecutionSettingsState();
}

class _BgExecutionSettingsState extends State<BgExecutionSettings> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _setDefaults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Background Execution Settings")),
      body: Column(
        children: [
          ListTile(
            title: Text("Enabled"),
            subtitle: Text(
                "This is required to use features like, absent notification, attendance change and others."),
            trailing: Switch(
              value: _enabled,
              onChanged: (value) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                if (value) {
                  await prefs.setInt(kPrefs_BackgroundServiceInterval, 30);
                } else {
                  await prefs.remove(kPrefs_BackgroundServiceInterval);
                }

                setState(() {
                  _enabled = value;
                });
              },
            ),
          ),
          Visibility(
            visible: _enabled,
            child: TextButton(
              child: Text("Edit Interval"),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                TextEditingController intervalController =
                    TextEditingController();
                GlobalKey<FormState> key = GlobalKey<FormState>();

                intervalController.text =
                    (prefs.getInt(kPrefs_BackgroundServiceInterval) ?? 30)
                        .toString();

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Edit Interval"),
                    content: Form(
                      key: key,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Smaller interval will increase battery usage and larger interval may cause the app to ignore the execution."),
                          TextFormField(
                            controller: intervalController,
                            decoration: InputDecoration(hintText: "Seconds"),
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return "Enter a interval";

                              if (int.parse(value ?? "0") < 15)
                                return "Value must be greater than 15 seconds!";

                              return null;
                            },
                            onChanged: (_) => key.currentState!.validate(),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          if (key.currentState!.validate()) {
                            await prefs.setInt(kPrefs_BackgroundServiceInterval,
                                int.parse(intervalController.text));

                            FlutterBackgroundService().invoke("stopService");
                            await initializeBackgroundService();

                            await Provider.of<AppState>(context, listen: false)
                                .refresh();

                            Navigator.of(context).pop();
                          }
                        },
                        child: Text("Save"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _setDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getInt(kPrefs_BackgroundServiceInterval) != null;
    });
  }
}
