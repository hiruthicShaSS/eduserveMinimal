// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/service/currency_to_unicode.dart';
import 'package:eduserveMinimal/models/fees.dart';

class FeeContainer extends StatelessWidget {
  const FeeContainer({Key? key, required this.fee}) : super(key: key);

  final SingleFee fee;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(fee.description),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Semester: ${fee.semester}"),
                Text("To Pay: ${fee.toPay}"),
                Text(
                    "Last Date: ${DateFormat("yyyy-MM-dd").format(fee.lastDate)}"),
                Text("Currency: ${fee.currency}"),
                Text("Paid: ${fee.paid}"),
                Text("Receipt: ${fee.receiptNo}"),
                Text(
                    "Date of Payment: ${fee.dateOfPayment == null ? "Yet to be paid" : DateFormat("yyyy-MM-dd").format(fee.dateOfPayment!)}"),
                Text("Net Dues: ${fee.netDues}"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  String data =
                      "${fee.description}\nSemester: ${fee.semester}\nReciept no: ${fee.receiptNo}\nAmount: ${fee.paid}\nDate of Payment: ${fee.dateOfPayment == null ? "Yet to be paid" : DateFormat("yyyy-MM-dd").format(fee.dateOfPayment!)}\nCurrency: ${fee.currency}";

                  Clipboard.setData(ClipboardData(text: data));
                  Fluttertoast.showToast(msg: "Copied to clipboard");
                },
                child: Text("Copy to clipboard"),
              )
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: Colors.black,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: fee.dateOfPayment == null
                  ? Icon(Icons.label_important, color: Colors.red)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat("dd").format(fee.dateOfPayment!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat("MMM").format(fee.dateOfPayment!),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    fee.description,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    fee.receiptNo ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyToUnicode(fee.currency) + fee.paid.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                if (fee.paid != fee.toPay)
                  Row(
                    children: [
                      if (fee.paid != fee.toPay)
                        Icon(Icons.request_page, color: Colors.red),
                      Text(
                        currencyToUnicode(fee.currency) + fee.toPay.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
