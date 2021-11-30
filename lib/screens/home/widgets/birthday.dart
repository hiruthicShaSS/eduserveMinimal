import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BirthDayWidget extends StatelessWidget {
  const BirthDayWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: SafeArea(
            child: Container(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Lottie.asset("assets/lottie/confetti.json",
                      repeat: false),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Lottie.asset(
                              "assets/lottie/happy_birthday.json",
                              repeat: false),
                        ),
                        Expanded(
                          child: Lottie.asset(
                              "assets/lottie/gifts.json",
                              fit: BoxFit.fill),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Text(
                            "Hope you get more gifts and party all day!!! 😊",
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close)),
                ],
              ),
            ),
          ),
        );
  }
}
