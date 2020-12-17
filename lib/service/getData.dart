import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Services {
  static var cacheData = {};

  Map getData() {
    return cacheData;
  }

  Future<Map> getDataFromCloud() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    
    if (cacheData.keys.length != 0) {
      return getData();
    }

    String driveLink = prefs.getString("link");
    var response = await http.get(driveLink);
    Map data = jsonDecode(response.body);
    cacheData = data;
    cacheData["downloaded"] = true;
    return cacheData;
  }
}
