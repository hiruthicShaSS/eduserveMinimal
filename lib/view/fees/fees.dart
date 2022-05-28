// 🐦 Flutter imports:
import 'package:eduserveMinimal/global/service/currency_to_unicode.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/view/fees/widgets/fee_container.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/models/fees.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:provider/provider.dart';

class FeesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: Provider.of<AppState>(context).fees,
          builder: (context, AsyncSnapshot<Fees> snapshot) {
            if (snapshot.hasData) {
              Fees fees = snapshot.data!;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                              child: AutoSizeText(
                                "Advance: ${fees.advance}",
                                minFontSize: 15,
                                maxFontSize: 22,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.comfortaa(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: ThemeProvider
                                  .currentThemeData!.primaryColor
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: AutoSizeText(
                                "Total spent: ${currencyToUnicode(fees.all.first.currency)} ${fees.all.fold<double>(0, (previousValue, fee) => previousValue + fee.paid)}",
                                minFontSize: 15,
                                maxFontSize: 22,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.comfortaa(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 15),
                      //   child: IconButton(
                      //     onPressed: () async {
                      //       await downloadFeeStatement();
                      //     },
                      //     icon: Icon(Icons.download),
                      //   ),
                      // )
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: fees.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          child: FeeContainer(fee: fees.all[index]),
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
