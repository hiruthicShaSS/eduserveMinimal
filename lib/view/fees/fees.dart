// 🐦 Flutter imports:
import 'package:eduserveMinimal/global/service/currency_to_unicode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/models/fees.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/service/fees_details.dart';
import 'package:intl/intl.dart';

class FeesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: getFeesDetails(),
          builder: (context, AsyncSnapshot<Fees> snapshot) {
            if (snapshot.hasData) {
              Fees fees = snapshot.data!;

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
                              color: fees.totalDues <= 0
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                                child: AutoSizeText(
                              "Total Due: ${fees.totalDues}",
                              minFontSize: 15,
                              maxFontSize: 22,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.comfortaa(
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            height: 50,
                            width: _width / 2.2,
                            decoration: BoxDecoration(
                              color:
                                  ThemeProvider.currentThemeData!.primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                                child: AutoSizeText("Advance: ${fees.advance}",
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
                      itemCount: fees.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListTile(
                            tileColor:
                                ThemeProvider.currentThemeData!.cardColor,
                            title: AutoSizeText(fees.values[index].description),
                            leading: AutoSizeText(
                              DateFormat("dd-MM-yyyy")
                                  .format(fees.all[index].dateOfPayment),
                              minFontSize: 12,
                              maxFontSize: 18,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              children: [
                                AutoSizeText(
                                  "${currencyToUnicode(fees.values[index].currency)} ${fees.values[index].paid}",
                                  minFontSize: 18,
                                  maxFontSize: 24,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.red),
                                ),
                                AutoSizeText(
                                  fees.all[index].recieptNo,
                                  minFontSize: 12,
                                  maxFontSize: 18,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text:
                                      "${fees.values[index].description}\nReciept no. : ${fees.ids[index]}\nAmount: ${fees.values[index].paid}\nDate Payed: ${fees.values[index].dateOfPayment}"));
                              Fluttertoast.showToast(
                                  msg: "Copied to clipboard");
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}