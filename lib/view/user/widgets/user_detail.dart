// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class UserDetailWidget extends StatelessWidget {
  const UserDetailWidget({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
      child: Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }
}
