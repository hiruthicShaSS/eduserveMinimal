import 'package:eduserveMinimal/edu_serve_minimal.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CredentialsForm extends StatefulWidget {
  const CredentialsForm({Key? key}) : super(key: key);

  @override
  State<CredentialsForm> createState() => _CredentialsFormState();
}

class _CredentialsFormState extends State<CredentialsForm> {
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _autoFillFeedbackValue = 1;
  bool _autoFillFedbackForm = false;

  @override
  void initState() {
    _setDefaults();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: "Somethin like... URK19CS2017",
              filled: true,
              fillColor: Colors.transparent.withOpacity(0.2),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Enter a value";
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Probably your birthday...",
              filled: true,
              fillColor: Colors.transparent.withOpacity(0.2),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Enter a value";
              return null;
            },
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                Text("Autofill feedback form: "),
                Checkbox(
                    value: _autoFillFedbackForm,
                    onChanged: (value) =>
                        setState(() => _autoFillFedbackForm = value ?? false)),
                Visibility(
                  visible: _autoFillFedbackForm,
                  child: DropdownButton(
                    hint: Text("Default rating"),
                    value: _autoFillFeedbackValue,
                    items: List.generate(
                      5,
                      (index) => DropdownMenuItem(
                        child: Text((index + 1).toString() +
                            (index == 0 ? " star" : " stars")),
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
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _onSave,
            child: Text("SAVE"),
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              fixedSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width, 45),
              ),
            ),
          ),
          // TextButton(
          //   child: Text("Forgot password?"),
          //   onPressed: () {
          //     Navigator.of(context).pushNamed("/forgotPassword");
          //   },
          //   style: ButtonStyle(
          //     overlayColor: MaterialStateProperty.all(Colors.transparent),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _setDefaults() async {
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

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FlutterSecureStorage storage = FlutterSecureStorage();

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
    await AuthService().login(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    Navigator.of(context).pop();

    await storage.write(key: "username", value: _usernameController.text);
    await storage.write(key: "password", value: _passwordController.text);

    if (_autoFillFedbackForm) {
      await prefs.setInt("autoFillFeedbackValue", _autoFillFeedbackValue);
    }

    Fluttertoast.showToast(msg: "Credentials updated successfully");

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => HomeController()));
  }
}
