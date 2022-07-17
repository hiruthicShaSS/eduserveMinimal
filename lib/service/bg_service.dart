// 🎯 Dart imports:
import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/check_absent.dart';

import 'check_for_attendance_change.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

// to ensure this executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  log("Background service started");

  // service.on('setAsForeground').listen((event) {
  //   service.setAsForegroundService();
  // });

  // service.on('setAsBackground').listen((event) {
  //   service.setAsBackgroundService();
  // });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Background Service",
      content: "Please hide this notification channel!",
    );
  }

  Timer.periodic(const Duration(hours: 4),
      (timer) => checkForAbsent(showNotification: true));

  Timer.periodic(const Duration(hours: 6),
      (timer) => checkForAttendanceChange(showNotification: true));
}
