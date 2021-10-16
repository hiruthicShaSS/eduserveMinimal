import 'package:eduserveMinimal/providers/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Themes extends StatelessWidget {
  const Themes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Themes"),
        centerTitle: true,
      ),
      body: ListView(
        children: List.generate(
          ThemeMode.values.length,
          (index) => ListTile(
            title: Text(ThemeMode.values[index]
                .toString()
                .split(".")
                .last
                .toUpperCase()),
            trailing: Visibility(
                visible: Provider.of<ThemeProvider>(context, listen: false)
                        .themeMode ==
                    ThemeMode.values[index],
                child: Icon(Icons.check_circle_outline, color: Colors.green)),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false)
                  .setThemeMode(ThemeMode.values[index]);
            },
          ),
        ),
      ),
    );
  }
}
