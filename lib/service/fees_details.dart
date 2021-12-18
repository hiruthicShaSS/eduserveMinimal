// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

// Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:eduserveMinimal/service/scrap.dart';

Future<Map?> getFeesDetails({bool force = false}) async {
  if (Scraper.cache.containsKey("fees")) return Scraper.cache["fees"];
  Map<String, String> headers = httpHeaders;

  String feesDownload = "/Student/Fees/DownloadReceipt.aspx";
  String feesOverallStatement = "/Student/Fees/FeesStatement.aspx";
  Map feesStatement = new Map();

  Response page = await get(
      Uri.parse("https://eduserve.karunya.edu${feesDownload}"),
      headers: headers);

  if (page.body.indexOf("Login") != -1) {
    Fluttertoast.showToast(msg: "esM: Session expired. Refresh data!");
    return null;
  }

  Response dues = await get(
      Uri.parse("https://eduserve.karunya.edu${feesOverallStatement}"),
      headers: headers);
  var dueSoup = Beautifulsoup(dues.body);
  List dueslist = dueSoup
      .find_all("span")
      .map((e) => (e.attributes["id"] == "mainContent_LBLDUES" ||
              e.attributes["id"] == "mainContent_LBLEXCESS")
          ? e.text
          : "")
      .toSet()
      .toList();
  dueslist.removeWhere((element) => element == "");

  var soup = Beautifulsoup(page.body);
  List table = soup.find_all("tr").map((e) => e.innerHtml).toSet().toList();

  bool flagReached = false;
  table.forEach((element) {
    if (element.indexOf("Total Amount") != -1) {
      flagReached = true;
      return;
    }
    if (flagReached) {
      element = element.trim().replaceAll("<td>", "");
      element = element.trim().replaceAll('<td style="display:none;">', "");
      element = element.trim().replaceAll("</td>", "<space>");

      List? temp = [];
      temp = element.split("<space>");
      temp!.removeRange(0, 3);
      temp.removeWhere((element) => element.length == 0);
      feesStatement[temp[1]] = temp;
    }
  });

  feesStatement["dues"] = dueslist;
  Scraper.cache["fees"] = feesStatement;
  return feesStatement;
}
