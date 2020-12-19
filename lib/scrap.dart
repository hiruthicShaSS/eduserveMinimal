import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:requests/requests.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

void login() async {
  String url =
      "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=/Student/Home.aspx";
  Map<String, String> headers = {
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36 Edg/87.0.664.66",
    "accept":
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "content-type": "application/x-www-form-urlencoded"
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

  Client client = new Client();
  var res = await client.get(url, headers: headers);
  var soup = Beautifulsoup(res.body);
  final inputs = soup.find_all("input").map((e) => e.attributes).toList();

  inputs.forEach((element) {
    if (login_data[element["name"]] == "") {
      login_data[element["name"]] = element["value"];
    }
  });

  // var r = await Requests.get(url, headers: headers, body: login_data);
  // r.raiseForStatus();
  // String body = r.content();
  // print(body);

  res = await client.post(url, headers: headers, body: Uri.encodeComponent(login_data.toString()));
  print(res.body);
  if (res.statusCode == 302) {
    // res = await client
    //     .get("https://eduserve.karunya.edu" + res.headers["location"]);

    
    // print(res.body);
    // print(res.body.indexOf("ANDREW"));
  }

  String subString(source, substring) {
    final startIndex = source.indexOf(substring);
    final endIndex = startIndex + substring.length + 100;

    return source.substring(startIndex + substring.length, endIndex).trim();
  }
  // print(subString(body, "__VIEWSTATEGENERATOR"));
}

void main() {
  login();
}
