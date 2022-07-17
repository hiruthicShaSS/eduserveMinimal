import 'package:flutter/material.dart';

class RestartProvider extends ChangeNotifier {
  void restart() => notifyListeners();
}
