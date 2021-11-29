// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

// Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';

Future getInternalMarks({String? academicTerm = null}) async {
  final String internalsURL = "/Student/InternalMarks.aspx";
  Map<String, String> headers = httpHeaders;
  Map formData = httpFormData;

  if (academicTerm == null) {
    Response res = await get(
        Uri.parse("https://eduserve.karunya.edu$internalsURL"),
        headers: headers);

    if (res.body.indexOf("Login") != -1) {
      Fluttertoast.showToast(msg: "esM: Session expired. Refresh data!");
      return;
    }

    var soup = Beautifulsoup(res.body);
    final inputs = soup.find_all("input").map((e) => e.attributes).toList();
    List academicTerms =
        soup.find_all("option").map((e) => e.text.trim()).toSet().toList();

    inputs.forEach((element) {
      // Populate form data
      if (formData[element["name"]] == "") {
        formData[element["name"]] =
            (element["value"] == "Clear" || element["value"] == null)
                ? ""
                : element["value"];
      }
    });

    formData["ctl00\$mainContent\$DDLACADEMICTERM"] = academicTerm;

    return academicTerms;
  } else {
    Map formdata = formData;
    formdata["ctl00\$mainContent\$DDLACADEMICTERM"] = academicTerm.toString();
    formdata.remove("ctl00\$mainContent\$DDLEXAM");
    Response res = await post(
        Uri.parse("https://eduserve.karunya.edu$internalsURL"),
        headers: headers,
        body: formdata);

    if ((res.body.indexOf("No records to display.") != -1)) {
      return "No records to display.";
    }

    var soup = Beautifulsoup(res.body);
    List table = soup.find_all("tr").map((e) => e.innerHtml).toSet().toList();

    bool flagReached = false;
    Map data = new Map();
    table.forEach((element) {
      if (element.indexOf("Entered by") != -1) {
        flagReached = true;
        return;
      }
      if (flagReached) {
        element = element.trim().replaceAll("<td>", "");
        element = element.trim().replaceAll("</td>", "<space>");

        data[element.split("<space>")[8]] = element.split("<space>");
        data[element.split("<space>")[8]]
            .removeWhere((element) => element == "");
      }
    });

    return Map.of(data);
  }
}
