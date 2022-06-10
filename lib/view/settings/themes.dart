// 🐦 Flutter imports:
import 'package:eduserveMinimal/global/enum.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/providers/theme.dart';

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
          AppTheme.values.length,
          (index) => ListTile(
            title: Text(AppTheme.values[index]
                .toString()
                .split(".")
                .last
                .toUpperCase()),
            trailing: Visibility(
                visible: Provider.of<ThemeProvider>(context, listen: false)
                        .currentAppTheme ==
                    AppTheme.values[index],
                child: Icon(Icons.check_circle_outline, color: Colors.green)),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false)
                  .applyTheme(AppTheme.values[index]);
            },
          ),
        ),
      ),
    );
  }
}
