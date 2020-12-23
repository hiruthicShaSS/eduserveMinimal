import 'package:eduserveMinimal/views/home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class User extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Center(
          child: GestureDetector(
            child: CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(Home.cloudData["studentIMG"]),
              backgroundColor: Colors.transparent,
              onBackgroundImageError: (_, __) {
                return Image.asset("assets/placeholder_profile.png");
              },
            ),
            onTap: () {
              Fluttertoast.showToast(msg: "Update profile, feature coming soon!😊");
            },
          ),
        ),
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
            Text("Name: ${Home.cloudData['name']}"),
            Text("Register Number: ${Home.cloudData['reg']}"),
            Text("Dept. : ${Home.cloudData['programme']}"),
            Text("KMail : ${Home.cloudData['kmail']}"),
            Text("Mobile : ${Home.cloudData['mobile']}"),
            Text("Mentor : ${Home.cloudData['mentor']}"),
            Text("Credits : ${Home.cloudData['credits']}"),
            Text("CGPA : ${Home.cloudData['cgpa']}"),
            Text("SGPA : ${Home.cloudData['sgpa']}"),
            Text(
                "Non Academic Credits : ${Home.cloudData['nonAcademicCredits']}"),
            Text("CGPA : ${Home.cloudData['cgpa']}"),
          ],
        )
      ],
    );
  }
}
