import 'package:auto_size_text/auto_size_text.dart';
import 'package:eduserveMinimal/main.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class Fees extends StatelessWidget {
  Future<Map> getFeesStatement({bool force = false}) async {
    Scraper scraper = MyHomePage.scraper;
    return await scraper.fees(force: force);
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Fees"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await getFeesStatement(force: true);
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Fees(),
              ));
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: getFeesStatement(),
        builder: (context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            Map data = snapshot.data;
            List dues = (data["dues"] == null || data["dues"].length < 2)
                ? [0, 0]
                : data["dues"];
            data.remove("dues");

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          height: 50,
                          width: _width / 2.2,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                              child: AutoSizeText("Total Due: ${dues[0]}",
                                  minFontSize: 15,
                                  maxFontSize: 22,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.comfortaa(
                                      fontWeight: FontWeight.bold))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          height: 50,
                          width: _width / 2.2,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                              child: AutoSizeText("Excess Fee: ${dues[1]}",
                                  minFontSize: 15,
                                  maxFontSize: 22,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.comfortaa(
                                      fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.keys.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ListTile(
                          tileColor: Colors.black,
                          title:
                              AutoSizeText(data[data.keys.toList()[index]][2]),
                          trailing: Column(
                            children: [
                              AutoSizeText(
                                data[data.keys.toList()[index]][1], // Amount
                                minFontSize: 18,
                                maxFontSize: 24,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.red),
                              ),
                              AutoSizeText(
                                data.keys.toList()[index], // Reciept number
                                minFontSize: 12,
                                maxFontSize: 18,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AutoSizeText(
                                data[data.keys.toList()[index]][0], // Date
                                minFontSize: 6,
                                maxFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          onTap: () {
                            // ClipboardManager.copyToClipBoard(
                            //         "${data[data.keys.toList()[index]][2]}\nReciept no. : ${data.keys.toList()[index]}\nAmount: ${data[data.keys.toList()[index]][1]}\nDate Payed: ${data[data.keys.toList()[index]][0]}")
                            //     .then((result) {
                            //   Fluttertoast.showToast(
                            //       msg: "Copied to clipboard");
                            // });
                            Clipboard.setData(ClipboardData(
                                text:
                                    "${data[data.keys.toList()[index]][2]}\nReciept no. : ${data.keys.toList()[index]}\nAmount: ${data[data.keys.toList()[index]][1]}\nDate Payed: ${data[data.keys.toList()[index]][0]}"));
                            Fluttertoast.showToast(msg: "Copied to clipboard");
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitCubeGrid(
                  color: Colors.white,
                  size: 50,
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(
                      "If the page takes longer to load, try refreshing the data and try again."),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
