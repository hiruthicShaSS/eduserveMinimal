// 🐦 Flutter imports:
import 'package:eduserveMinimal/service/auth.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/edu_serve.dart';
import 'package:eduserveMinimal/service/scrap.dart';

class Credentials extends StatefulWidget {
  final bool? pushHomePage;
  const Credentials({this.pushHomePage = false});

  @override
  State<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _autoFillFeedbackValue = 1;
  bool _autoFillFedbackForm = false;

  @override
  void initState() {
    super.initState();
    setDefaults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text("Enter Credentials", style: TextStyle(fontSize: 30)),
                  SizedBox(height: 20),
                  buildTextField(_usernameController,
                      'Enter your register number.', false),
                  SizedBox(height: 20),
                  buildTextField(
                      _passwordController, 'Enter your password.', true),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text("Autofill feedback form: "),
                      Checkbox(
                          value: _autoFillFedbackForm,
                          onChanged: (value) => setState(
                              () => _autoFillFedbackForm = value ?? false)),
                      Visibility(
                        visible: _autoFillFedbackForm,
                        child: DropdownButton(
                          hint: Text("Default rating"),
                          value: _autoFillFeedbackValue,
                          items: List.generate(
                            5,
                            (index) => DropdownMenuItem(
                              child: Text((index + 1).toString()),
                              value: index + 1,
                            ),
                          ),
                          onChanged: (int? value) {
                            setState(() => _autoFillFeedbackValue = value ?? 1);
                          },
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    child: Text("Save"),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final FlutterSecureStorage storage =
                          FlutterSecureStorage();

                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Verifying credentials...",
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    ),
                                    CircularProgressIndicator(),
                                  ],
                                ),
                              ));
                      String loginStatus = await AuthService().login(
                        username: _usernameController.text,
                        password: _passwordController.text,
                      );

                      Navigator.of(context).pop();

                      if (loginStatus == "Login error") {
                        Fluttertoast.showToast(msg: "Login error");
                        return;
                      }

                      await storage.write(
                          key: "username", value: _usernameController.text);
                      await storage.write(
                          key: "password", value: _passwordController.text);

                      if (_autoFillFedbackForm) {
                        await prefs.setInt(
                            "autoFillFeedbackValue", _autoFillFeedbackValue);
                      }

                      Fluttertoast.showToast(
                          msg: "Credentials updated successfully");

                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => HomeController()));
                    },
                  ),
                  SizedBox(height: 30.0),
                  Text("Caution!",
                      style: GoogleFonts.kanit(
                        fontSize: 20,
                        color: Colors.red,
                      )),
                  Column(
                    children: [
                      Row(children: [
                        Icon(Icons.control_point),
                        SizedBox(width: 10),
                        Expanded(
                          child: AutoSizeText(
                            "Refreshing the data too many times will result in banning in eduserve. You will need to reset your password everytime you get banned.",
                            style: GoogleFonts.kanit(),
                            maxFontSize: 30,
                            minFontSize: 15,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                      SizedBox(height: 20),
                      Row(children: [
                        Icon(Icons.control_point),
                        SizedBox(width: 10),
                        Expanded(
                          child: AutoSizeText(
                            "If you feel the app doesn't work properly hard restart the app. If that doesnt help file a issue on github.\nSettings -> About -> Request Feature",
                            style: GoogleFonts.kanit(),
                            maxFontSize: 30,
                            minFontSize: 15,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ])
                    ],
                  ),
                  SizedBox(height: 50),
                  FutureBuilder(
                      future:
                          FlutterSecureStorage().containsKey(key: "username"),
                      builder: (context, AsyncSnapshot<bool> snapshot) {
                        return snapshot.hasData
                            ? Visibility(
                                visible: snapshot.data ?? false,
                                child: ElevatedButton(
                                  onPressed: () => Fluttertoast.showToast(
                                      msg: "Press and hold for action"),
                                  onLongPress: () => logout(context),
                                  child: Text("Logout"),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((states) => Colors.red),
                                  ),
                                ),
                              )
                            : Container();
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildTextField(
      TextEditingController _starsController, String hint, bool obscure) {
    return TextFormField(
      controller: _starsController,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
      ),
      validator: (value) {
        if (value == null) return "Enter a value";
        if (value == "") return "Enter a value";
        return null;
      },
    );
  }

  void logout(BuildContext context) {
    bool isLogOutClicked = false;

    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text("Logout"),
                content: Text("Are you sure you want to logout?"),
                actions: [
                  TextButton(
                    onPressed: () async {
                      setState(() => isLogOutClicked = true);
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final FlutterSecureStorage storage =
                          FlutterSecureStorage();

                      await storage.delete(key: "username");
                      await storage.delete(key: "password");
                      await prefs.remove("autoFillFeedbackValue");
                      Scraper.cache = {};

                      Fluttertoast.showToast(msg: "Logout completed");
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          "/credentials", (route) => false);
                    },
                    child: isLogOutClicked
                        ? SizedBox(width: 80, child: LinearProgressIndicator())
                        : Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.green),
                    ),
                  ),
                ],
              );
            }));
  }

  void setDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FlutterSecureStorage storage = FlutterSecureStorage();

    _usernameController.text = await storage.read(key: "username") ?? "";
    _passwordController.text = await storage.read(key: "password") ?? "";

    if (mounted) {
      setState(() {
        _autoFillFedbackForm = prefs.containsKey("autoFillFeedbackValue");
        _autoFillFeedbackValue = prefs.getInt("autoFillFeedbackValue") ?? 1;
      });
    }
  }
}
