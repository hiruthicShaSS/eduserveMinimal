// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({
    Key? key,
    required this.title,
    required this.data,
    this.color,
  }) : super(key: key);

  final String title;
  final String? data;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(20),
        width: 120,
        decoration: BoxDecoration(
          color: (color ?? Colors.transparent).withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            AutoSizeText(
              title,
              minFontSize: 15,
              maxFontSize: 20,
            ),
            SizedBox(height: 10),
            Text(data!),
          ],
        ),
      ),
    );
  }
}
