import 'package:http/http.dart';
import 'package:beautifulsoup/beautifulsoup.dart';

class Scraper {
  static String status = "";

  Future<String> login() async {
    String hostname = "https://eduserve.karunya.edu";
    String loginAddress = "/Login.aspx?ReturnUrl=%2f";
    String url = "";

    Map<String, String> headers = {
      "user-agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36 Edg/87.0.664.66",
      "accept":
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "content-type": "application/x-www-form-urlencoded",
      "origin": "https://eduserve.karunya.edu",
      "referer": url,
      "sec-fetch-dest": "document",
      "sec-fetch-mode": "navigate",
      "sec-fetch-site": "same-origin",
      "sec-fetch-user": "?1",
      "upgrade-insecure-requests": "1"
    };

    Map<String, String> login_data = {
      "RadScriptManager1_TSM": "",
      "__EVENTTARGET": "",
      "__EVENTARGUMENT": "",
      "__VIEWSTATE": "",
      "__VIEWSTATEGENERATOR": "",
      "__EVENTVALIDATION": "",
      "ctl00\$mainContent\$Login1\$UserName": "urk19cs2017",
      "ctl00\$mainContent\$Login1\$Password": "accesseduserve",
      "ctl00\$mainContent\$Login1\$LoginButton": "Log In"
    };

    status = "Get EduServe...";
    Client client = new Client();

    // Get karunya.edu
    url = hostname;
    headers["referer"] = url;
    var res = await client.get(url);
    var eduserveCookie = res.headers["set-cookie"]; // Set the ASP.NET_SessionId

    // Parse: Start
    var soup = Beautifulsoup(res.body);
    final inputs = soup.find_all("input").map((e) => e.attributes).toList();

    inputs.forEach((element) {
      if (login_data[element["name"]] == "") {
        login_data[element["name"]] = element["value"];
      }
    });
    // Parse: End

    // Get login.aspx
    status += "\nLogging in...";
    headers["cookie"] = eduserveCookie.split(";")[0];
    url = hostname + loginAddress;
    headers["referer"] = url;

    // Post to login.aspx
    res = await client.post(url, headers: headers, body: login_data);

    if (res.statusCode == 302) {
      status += "\nRedirecting to Home";
      headers["cookie"] += "; ${res.headers['set-cookie'].split(';')[0]}";
      res = await client.get(
          "https://eduserve.karunya.edu${res.headers["location"]}",
          headers: headers);
    }

    return res.body;
  }

  Future<Map> parse() async {
    String studentHomePage = await login();
    status += "\nScrapping data...";

    var soup = Beautifulsoup(studentHomePage);
    List basicInfo =
        soup.find_all("span").map((e) => (e.innerHtml)).toList().sublist(54);
    String studentImage =
        soup.find_all("img").map((e) => (e.attributes["src"])).toList()[2];
    List td = soup.find_all("td").map((e) => (e.text)).toList();

    bool flagReached = false;
    int flagLines = 0;
    Map leaveApplication = new Map();

    RegExp leaveTypeExp = new RegExp(r"[^\d\s].*Leave");
    RegExp leaveReasonExp = new RegExp(r"[^\d\s].*Leave");
    RegExp leaveDurationExp = new RegExp(
        r"(\d{1,}\s\w{1,3}\s\d{1,4})\s\w.*(\d{1,}\s\w{1,3}\s\d{1,4})\s.+Day");

    String temp = "";
    td.forEach((element) {
      element = element.trim();

      if (leaveTypeExp.hasMatch(element)) {
        flagReached = true;
      }
      if (flagReached) {
        if (flagLines != 7) {
          temp += "$element<space>";
          flagLines++;
        } else {
          List splited = temp.split("<space>");
          splited.asMap().forEach((i, value) {
            try {
              int.parse(element[i]);
              return;
            } catch (e) {}
            splited[i] = splited[i].trim();
          });
          splited.removeWhere(
              (element) => element.toString() == ""); // Remove empty elements
          leaveApplication[splited[1]] = splited;

          flagLines = 0;
          temp = "";
        }
        print(leaveApplication);
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
    status += "Done.";
    return await parse();
  }
}

// Request on /:
// "cookie: ASP.NET_SessionId=4kgjcbdm5aj4jirzrn13axn3; .ASPXAUTH=AF2E3E04139BF16180E27AFC85529AB27E00B725372C66B20DE762C75F8DDDAA8950DAD858D3AE9A0487CB75FDC3343B7AEC10DB4028F4C49A37C8806B523BC975B9D0E1DC0954ADBFEF8D1002F9699FBC11CEBEECFBE89DFEC849EE8C313A52BC5C11FC"

// Response on login.aspx:
// "set-cookie: .ASPXAUTH=AF2E3E04139BF16180E27AFC85529AB27E00B725372C66B20DE762C75F8DDDAA8950DAD858D3AE9A0487CB75FDC3343B7AEC10DB4028F4C49A37C8806B523BC975B9D0E1DC0954ADBFEF8D1002F9699FBC11CEBEECFBE89DFEC849EE8C313A52BC5C11FC; path=/; secure; HttpOnly; SameSite=Lax"

// Request to login [POST]:
// "ookie: ASP.NET_SessionId=4kgjcbdm5aj4jirzrn13axn3; .ASPXAUTH=EDC6E8F6DAAE0EE5871CB47A3C7B6A132ED571C9228C79A966D9EEC7DFD214342AFA53B41AB56B42D3896B60A50564F376F3089FBD496037FBEDE86B0EEFC2494B2C6792187B1B97417B10DE9E5F6A8B2684982701ED4A03178AEFD9052BB5DA5F2FDB90"

// Request to home.aspx [GET]:
// cookie: ASP.NET_SessionId=4kgjcbdm5aj4jirzrn13axn3; .ASPXAUTH=AF2E3E04139BF16180E27AFC85529AB27E00B725372C66B20DE762C75F8DDDAA8950DAD858D3AE9A0487CB75FDC3343B7AEC10DB4028F4C49A37C8806B523BC975B9D0E1DC0954ADBFEF8D1002F9699FBC11CEBEECFBE89DFEC849EE8C313A52BC5C11FC
