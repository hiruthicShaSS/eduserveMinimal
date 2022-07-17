// 📦 Package imports:
import 'dart:math';

import 'package:html/dom.dart';
import 'package:http/http.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/auth.dart';

Future<bool> fillFeedbackForm(Map rating) async {
  Map formData = AuthService.formData;

  formData["ctl00_radMenu_ClientState"] = "";
  formData["__SCROLLPOSITIONX"] = Random().nextInt(1000).toString();
  formData["__SCROLLPOSITIONY"] = "0";
  formData.remove("ctl00_radMenuModule_ClientState");
  formData.remove("ctl00_mainContent_grdData_ClientState");
  formData.remove("ctl00\$mainContent\$DDLACADEMICTERM");
  formData.remove("ctl00\$mainContent\$btnSave");
  formData["__EVENTARGUMENT"] = "undefined";
  formData["__PREVIOUSPAGE"] =
      "BBcWHSM0KrhqXb7r_Yk015qqDcTCfu1hhXzQ6dzxYY1bMmGMr3wJHQYHd04Jh6IvgLRduVXj5GSV23B6v_i4ThMCDXI1";

  Response res = await get(
    Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
    headers: AuthService.headers,
  );

  void setInputs(String body) {
    Document html = Document.html(res.body);
    final inputs = html
        .querySelectorAll("input")
        .map((e) => {e.attributes["name"]: e.attributes["value"]})
        .toList();

    inputs.removeWhere((element) =>
        element.keys.first == null || element.values.first == null);

    inputs.forEach((element) {
      if (formData[element["name"]] == "") {
        formData[element["name"]] =
            (element["value"] == "Clear" || element["value"] == null)
                ? ""
                : element["value"];
      }
    });
  }

  setInputs(res.body);

  rating.forEach((key, value) => formData[key] = "");

  bool feedbackSubmitted = false;
  for (int i = 0; i < rating.keys.toList().length; i++) {
    String key = rating.keys.toList()[i];
    key = key.replaceAllMapped(RegExp(r".*__"), (match) {
      if (match.group(0) != null)
        return match.group(0)! + "rtngHFB_ClientState";

      return "";
    });

    formData[key] = {
      "value": "\"${rating.values.toList()[i]}\"",
      "readOnly": "false"
    }.toString();

    String eventTarget = key.replaceAll("_ClientState", "");
    formData["__EVENTTARGET"] = eventTarget.replaceAll("_", "\$");

    Response res = await post(
      Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
      headers: AuthService.headers,
      body: formData,
    );

    formData.addAll(await AuthService().basicFormData(res.body));

    formData["ctl00_mainContent_grdHFB_ClientState"] =
        '{"selectedIndexes":["0"],"selectedCellsIndexes":[],"unselectableItemsIndexes":[],"reorderedColumns":[],"expandedItems":[],"expandedGroupItems":[],"expandedFilterItems":[],"deletedItems":[],"hidedColumns":[],"showedColumns":[],"groupColsState":{},"hierarchyState":{},"popUpLocations":{},"draggedItemsIndexes":[]}';

    print(res.statusCode);

    if (i + 1 == rating.keys.toList().length) {
      formData["ctl00\$mainContent\$btnSave"] = "Save";
      formData["__EVENTTARGET"] =
          r"ctl00$mainContent$grdHFB$ctl00$ctl04$rtngHFB";
      formData["__EVENTTARGET"] = "";
      formData["__EVENTARGUMENT"] = "";
      formData["__LASTFOCUS"] = "";

      res = await post(
        Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
        headers: AuthService.headers,
        body: formData,
      );

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
