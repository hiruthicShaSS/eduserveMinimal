import 'dart:async';
import 'dart:developer';

import 'package:eduserveMinimal/service/check_absent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
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
  // Only available for flutter 3.0.0 and later
  // DartPluginRegistrant.ensureInitialized();

  log("background service started");

  // service.on('setAsForeground').listen((event) {
  //   service.setAsForegroundService();
  // });

  // service.on('setAsBackground').listen((event) {
  //   service.setAsBackgroundService();
  // });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Background Service",
        content: DateTime.now().toIso8601String(),
      );
    }

    log('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
  });

  // Check if the user is abset yesterday every 8 hours
  Timer.periodic(const Duration(minutes: 10), (timer) => checkForAbsent());
}
