// 📦 Package imports:
import 'package:eduserveMinimal/service/auth.dart';
import 'package:http/http.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';

Future<bool> fillFeedbackForm(Map rating) async {
  Map<String, String> headers = AuthService.headers;
  Map formData = AuthService.formData;

  formData["ctl00_radMenu_ClientState"] = "";
  formData["__SCROLLPOSITIONX"] = "204";
  formData["__SCROLLPOSITIONY"] = "0";
  formData.remove("ctl00_radMenuModule_ClientState");
  formData.remove("ctl00_mainContent_grdData_ClientState");
  formData.remove("ctl00\$mainContent\$DDLACADEMICTERM");
  formData.remove("ctl00\$mainContent\$btnSave");

  Response res = await get(
    Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
    headers: headers,
  );

  formData.addAll(await AuthService().basicFormData(res.body));

  rating.forEach((key, value) => formData[key] = "");

  bool feedbackSubmitted = false;
  for (int i = 0; i < rating.keys.toList().length; i++) {
    formData[rating.keys.toList()[i]] = {
      "value": "\"${rating.values.toList()[i]}\"",
      "readOnly": "false"
    }.toString();

    String eventTarget = rating.keys.toList()[i].replaceAll("_ClientState", "");
    formData["__EVENTTARGET"] = eventTarget.replaceAll("_", "\$");

    Response res = await post(
        Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"));

    formData.addAll(await AuthService().basicFormData(res.body));

    print(res.statusCode);

    if (i + 1 == rating.keys.toList().length) {
      formData["ctl00\$mainContent\$btnSave"] = "Save";
      formData["__EVENTTARGET"] = "";
      res = await post(
          Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
          headers: headers,
          body: formData);

      print(res.statusCode);

      if (res.headers["location"] == "/Student/Home.aspx") {
        feedbackSubmitted = true;
      }
    }
  }

  await get(Uri.parse(
      "https://eduserve.karunya.edu/Student/Home.aspx")); // Making another request coz sometimes homepage doesnt load after feedback form
  return feedbackSubmitted;
}
