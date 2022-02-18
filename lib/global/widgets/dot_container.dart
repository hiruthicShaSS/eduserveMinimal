// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class DotContainer extends StatelessWidget {
  const DotContainer({Key? key, required this.color, required this.text})
      : super(key: key);

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Text(text),
      ],
    );
  }
}
