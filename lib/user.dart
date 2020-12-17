import 'package:eduserveMinimal/service/getData.dart';
import 'package:flutter/material.dart';

class User extends StatelessWidget {
  static Services services = new Services();
  Map cloudData = services.getData();

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
            Text("Name: ${cloudData['name']}"),
            Text("Register Number: ${cloudData['reg']}"),
            Text("Dept. : ${cloudData['programme']}"),
          ],
        )
      ],
    );
  }
}
