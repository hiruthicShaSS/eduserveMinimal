import 'package:eduserveMinimal/home.dart';
import 'package:flutter/material.dart';

class User extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Center(
          child: Image.network(
            Home.cloudData["studentIMG"],
            width: 200,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace stackTrace) {  // Return's plcaeholder image if the original link is not valid
              return Image.network(
                "https://img.icons8.com/dusk/512/000000/user-male-circle--v1.png",
                width: 200,
              );
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
