import 'dart:convert';

import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:http/http.dart';

Future<void> fillFeedbackForm(Map rating) async {
  Map formData = httpFormData;
  Map<String, String> headers = httpHeaders;

  formData["ctl00_radMenu_ClientState"] = "";
  formData["__SCROLLPOSITIONX"] = "204";
  formData["__SCROLLPOSITIONY"] = "0";
  formData.remove("ctl00_radMenuModule_ClientState");
  formData.remove("ctl00_mainContent_grdData_ClientState");
  formData.remove("ctl00\$mainContent\$DDLACADEMICTERM");

  Response res = await get(
    Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
    headers: headers,
  );

  Beautifulsoup soup = Beautifulsoup(res.body);
  void setInputs(String body) {
    Beautifulsoup soup = Beautifulsoup(body);
    final inputs = soup.find_all("input").map((e) => e.attributes).toList();

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

  List<String> course_ids =
      soup.find_all("tr").map((e) => e.id).toSet().toList();
  course_ids.removeWhere((e) => e == "");

  course_ids.forEach((element) => formData[element] = "");

  formData[course_ids.first] = {"value": "4", "readOnly": false}.toString();
  for (int i = 1; i < course_ids.length; i++) {
    post(Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"))
        .then((res) async {
      formData[course_ids[i]] = {"value": "4", "readOnly": false}.toString();

      setInputs(res.body);
      print(res.statusCode);

      if (i+1 == course_ids.length) {
        formData["ctl00\$mainContent\$btnSave"] = "Save";
        res = await post(
            Uri.parse(
                "https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
            headers: headers,
            body: formData);

        print(res.statusCode);
      }
    });
  }
}
