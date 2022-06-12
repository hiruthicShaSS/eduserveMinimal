// 📦 Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/auth.dart';

Future<void> cacheBirthDate() async {
  Response res = await get(
    Uri.parse("https://eduserve.karunya.edu/Student/PersonalInfo.aspx"),
    headers: AuthService.headers,
  );

  Document html = Document.html(res.body);

  String? dateString = html
      .querySelector("#ctl00_mainContent_TXTDOB_dateInput")
      ?.attributes["value"];

  if (dateString != null) {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    storage.write(key: "birthDay", value: dateString);
  }
}

Future<bool> checkBirthday() async {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  if (await storage.containsKey(key: "birthDay")) {
    String? birthday = await storage.read(key: "birthDay");

    if (birthday != null) {
      DateFormat dateFormat = DateFormat("dd MMM yyyy");
      DateTime birthDay = dateFormat.parse(birthday);
      DateTime today = DateTime.now();

      if (birthDay.month == today.month && birthDay.day == today.day) {
        return true;
      }

      return false;
    } else {
      await cacheBirthDate();
      return await checkBirthday();
    }
  } else {
    await cacheBirthDate();
    return await checkBirthday();
  }
}
