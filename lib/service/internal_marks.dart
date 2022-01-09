// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

// Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future getInternalMarks({String? academicTerm = null}) async {
  Scraper scraper = Scraper();
  await scraper.login();
  return await scraper.getInternalMarks();

  final String internalsURL = "/Student/InternalMarks.aspx";
  Map<String, String> headers = httpHeaders;
  Map formData = httpFormData;

  if (academicTerm == null) {
    Response res = await get(
        Uri.parse("https://eduserve.karunya.edu$internalsURL"),
        headers: headers);

    if (res.body.indexOf("Login") != -1) {
      Fluttertoast.showToast(msg: "Session expired. Refresh data!");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("isLoggedIn", false);
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
    headers["accept-encoding"] = "gzip, deflate, br";
    headers["accept-language"] = "en-US,en;q0.9";
    headers["cache-control"] = "max-age=0";
    // headers["content-length"] = "15695";
    headers["sec-ch-ua-platform"] = "Windows";
    headers["sec-ch-ua"] =
        "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"96\", \"Google Chrome\";v=\"96\"";
    headers["sec-ch-ua-mobile"] = "?0";

    formData["ctl00\$mainContent\$DDLACADEMICTERM"] = 20.toString();
    formData.remove("ctl00\$mainContent\$DDLEXAM");
    Response res = await post(
        Uri.parse("https://eduserve.karunya.edu$internalsURL"),
        headers: headers,
        body: formData);

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
