// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';

// Project imports:
import 'package:eduserveMinimal/service/login.dart';
import 'package:eduserveMinimal/service/scrap.dart';

Future<Map> parse() async {
  // Parse basic info
  // Parse the student basic info
  String studentHomePage = await login();

  var soup = Beautifulsoup(studentHomePage);
  List basicInfo =
      soup.find_all("span").map((e) => (e.innerHtml)).toList().sublist(54);
  String? studentImage =
      soup.find_all("img").map((e) => (e.attributes["src"])).toList()[2];
  List td = soup.find_all("td").map((e) => (e.text)).toList();

  bool flagReached = false;
  bool flagStop = false;
  int flagLines = 0;
  Map leaveApplication = new Map();

  RegExp leaveTypeExp = new RegExp(r"[^\d\s].*Leave");

  String temp = "";
  td.forEach((element) {
    if (!flagStop) {
      element = element.trim();
      if (element == "No records to display.") {
        flagStop = true;
      }

      if (leaveTypeExp.hasMatch(element)) {
        // if onDuty applications found set the flag to true.
        flagReached = true;
      }

      if (flagReached) {
        // Wait untill the onDuty applications found.
        if (flagLines != 8) {
          // 7 items in the application section -> [Leave Type, Reason, From Date, From Session, To Date, To Session, Status, Pending with]
          temp +=
              "$element<space>"; // Add each one of'em with delimiter : <space>
          flagLines++;
        } else {
          List splited =
              temp.split("<space>"); // Once completed parse the string to list.
          splited.removeWhere((element) => RegExp(r"\d{5,}").hasMatch(element));
          splited.asMap().forEach((i, value) {
            splited[i] = splited[i].trim();
          });
          splited.removeWhere(
              (element) => element.toString() == ""); // Remove empty elements.
          leaveApplication[splited[1]] = splited;

          flagLines = 0;
          temp = "";
        }
      }
    } else {
      return;
    }
  });

  basicInfo.add(studentImage);
  basicInfo.removeWhere(
      (element) => element.toString() == ""); // Remove empty elements
  basicInfo.remove("Academic Performance Summary");

  List basicInfoKeys = [
    "reg",
    "kmail",
    "name",
    "mobile",
    "programme",
    "mentor",
    "semester",
    "att",
    "asm",
    "cgpa",
    "arrears",
    "resultOf",
    "credits",
    "cgpa",
    "sgpa",
    "nonAcademicCredits",
    "studentIMG"
  ];

  // generate Map of infromation
  Map data = new Map();
  basicInfoKeys.asMap().forEach((i, element) {
    data[basicInfoKeys[i]] = basicInfo[i];
  });

  data["leaveApplications"] = leaveApplication;

  return data;
}

Future<Map> getInfo() async {
  if (Scraper.cache.containsKey("user")) return Scraper.cache["user"];

  Map data = await parse();
  data["dateScraped"] = DateTime.now().toString();
  Scraper.cache["user"] = data;
  return data;
}