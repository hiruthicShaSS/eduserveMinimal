import 'package:flutter/material.dart';

class User extends StatelessWidget {
  final String name = "hiruthicSha";
  final String register = "URK19CS2017";
  final String dob = "18/05/2002";
  final String dept = "CSE";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Center(
            child: Image.network(
          "https://img.icons8.com/dusk/512/000000/user-male-circle--v1.png",
          width: 200,
        )),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Divider(
            color: Colors.white,
            thickness: 2.0,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $name"),
            Text("Register Number: $register"),
            Text("D.O.B: $dob"),
            Text("Dept. : $dept"),
          ],
        )
      ],
    );
  }
}
