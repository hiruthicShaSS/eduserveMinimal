import 'package:eduserveMinimal/service/auth.dart';
import 'package:eduserveMinimal/view/settings/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key, this.username}) : super(key: key);

  final String? username;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _kmailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _resetting = false;
  late WebViewController _controller;

  @override
  void initState() {
    _usernameController.text = widget.username ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  SvgPicture.asset(
                    "assets/images/forgot-password.svg",
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                  const SizedBox(height: 60),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: "Somethin like... URK19CS2017",
                      filled: true,
                      fillColor: Colors.transparent.withOpacity(0.2),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 30.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Enter a value";
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      DateTime? dateTime = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now()
                            .add(const Duration(days: -18 * 30 * 12)),
                        firstDate: DateTime.now()
                            .add(const Duration(days: -80 * 30 * 12)),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 80 * 30 * 12)),
                      );

                      if (dateTime != null) {
                        setState(() {
                          _dobController.text =
                              DateFormat("dd MMM yyyy").format(dateTime);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _dobController,
                        decoration: InputDecoration(
                          hintText: "Date of Birth",
                          filled: true,
                          fillColor: Colors.transparent.withOpacity(0.2),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 30.0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                              width: 2.0,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Enter your DOB";

                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _kmailController,
                    decoration: InputDecoration(
                      hintText: "Karunya mail ID",
                      filled: true,
                      fillColor: Colors.transparent.withOpacity(0.2),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 30.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Enter a value";
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _resetting = true;
                        });

                        String body = await AuthService().forgotPassrword(
                          _usernameController.text,
                          _dobController.text,
                          _kmailController.text,
                        );

                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (_) => Test(body: body)));
                      }
                    },
                    child: Text(_resetting
                        ? "Sending you a random password..."
                        : "Reset Password"),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      fixedSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width, 45),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // floatingActionButton: Offstage(
        //   offstage: true,
        //   child: WebView(
        //     initialUrl: "https://eduserve.karunya.edu",
        //     javascriptMode: JavascriptMode.unrestricted,
        //     onWebViewCreated: (webViewController) async {
        //       _controller = webViewController;
        //     },
        //   ),
        // ),
      ),
    );
  }
}
