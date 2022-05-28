import 'package:eduserveMinimal/service/auth.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/models/fees.dart';
import 'package:intl/intl.dart';

Future<Fees> getFeesDetails() async {
  String feesDownload = "/Student/Fees/DownloadReceipt.aspx";
  String feesOverallStatement = "/Student/Fees/FeesStatement.aspx";

  Response page = await get(
    Uri.parse("https://eduserve.karunya.edu${feesDownload}"),
    headers: AuthService.headers,
  );

  if (page.body.indexOf("Login") != -1) {
    await AuthService().login();
  }

  Response res = await get(
    Uri.parse("https://eduserve.karunya.edu${feesOverallStatement}"),
    headers: AuthService.headers,
  );

  Document html = Document.html(res.body);

  double totalDues =
      double.parse(html.querySelector("#mainContent_LBLDUES")?.text ?? "0");
  double advance =
      double.parse(html.querySelector("#mainContent_LBLEXCESS")?.text ?? "0");

  List<Element> rows = html
      .querySelectorAll("tr")
      .where((e) => e.className == "rgRow" || e.className == "rgAltRow")
      .toList();

  Fees fees = Fees(totalDues: totalDues, advance: advance);

  for (var row in rows) {
    List<String> rowData = html
        .querySelectorAll("#${row.id} > td")
        .map((e) => e.text.trim())
        .toList();

    fees.add = SingleFee(
      description: rowData[3],
      semester: int.tryParse(rowData[4].split(" ").last) ?? 0,
      toPay: double.tryParse(rowData[5]) ?? 0,
      lastDate: DateFormat("dd-MM-yyyy").parse(rowData[6]),
      currency: rowData[8],
      paid: double.tryParse(rowData[9]) ?? 0,
      receiptNo: rowData[10],
      dateOfPayment: DateFormat("yyyy-MM-dd").parse(rowData[11]),
      netDues: double.tryParse(rowData[13]) ?? 0,
    );
  }

  return fees;
}

Future<void> downloadFeeStatement() async {
  Map<String, String> formData = AuthService.formData;

  formData["__EVENTTARGET"] = "";
  formData["__EVENTARGUMENT"] = "";
  formData[r"ctl00_radMenuModule_ClientState"] = "";
  formData[r"ctl00_mainContent_grdData_ClientState"] =
      '{"selectedIndexes":[],"selectedCellsIndexes":[],"unselectableItemsIndexes":[],"reorderedColumns":[],"expandedItems":[],"expandedGroupItems":[],"expandedFilterItems":[],"deletedItems":[],"hidedColumns":[],"showedColumns":[],"groupColsState":{},"hierarchyState":{},"scrolledPosition":"545.5999755859375,0","popUpLocations":{},"draggedItemsIndexes":[]}';
  formData[r"ctl00$mainContent$btnDownload"] = "Download";

  Response res = await post(
    Uri.parse("https://eduserve.karunya.edu/Student/Fees/FeesStatement.aspx"),
    headers: AuthService.headers,
    body: formData,
  );

  print(res.body);
}
