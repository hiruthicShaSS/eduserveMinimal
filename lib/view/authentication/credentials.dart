// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'widgets/credentials_form.dart';

class Credentials extends StatefulWidget {
  final bool? pushHomePage;
  const Credentials({this.pushHomePage = false});

  @override
  State<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {
  late bool isFromAuth;

  @override
  void initState() {
    FlutterBackgroundService().invoke("stopService");
    super.initState();
  }

  @override
  void didChangeDependencies() {
    isFromAuth = ModalRoute.of(context)?.settings.arguments == null;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        reverse: true,
        child: Stack(
          children: [
            Positioned(
              top: -20,
              left: -70,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Positioned(
              top: 150,
              right: -40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: isFromAuth ? 150 : 200),
                Text(
                  isFromAuth ? "Welcome yo," : "Update Credentials",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: isFromAuth ? 0 : 20),
                if (isFromAuth == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SvgPicture.asset(
                      "assets/images/login.svg",
                      height: MediaQuery.of(context).size.height * 0.3,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: CredentialsForm(isFromAuth: isFromAuth),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
