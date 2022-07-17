// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/constants.dart';
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/providers/cache.dart';
import 'package:eduserveMinimal/service/internal_marks.dart';
import 'package:eduserveMinimal/view/home/internal_exams/widgets/internal_marks_table.dart';

class InternalMarksScreen extends StatefulWidget {
  @override
  _InternalMarksScreenState createState() => _InternalMarksScreenState();
}

class _InternalMarksScreenState extends State<InternalMarksScreen> {
  String? dropdownSelection;
  InternalMarksService internalMarksService = InternalMarksService();
  List<String> academicTerms = [];
  int? selectedAcademicTerm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: Provider.of<CacheProvider>(context)
                  .getInternalAcademicTerms(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasError) {
                  log(snapshot.error.toString());

                  if (snapshot.error.runtimeType == NetworkException) {
                    return Center(child: Text(kNoInternetText));
                  }
                }

                if (snapshot.hasData) {
                  academicTerms = snapshot.data;
                  academicTerms.remove("Select the Academic Term");

                  return Center(
                    child: DropdownButton(
                      hint: Text("Select the Academic Term"),
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      underline: Container(height: 2),
                      value: dropdownSelection,
                      items: academicTerms
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: value == dropdownSelection
                                ? TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) async {
                        setState(() {
                          dropdownSelection = value.toString();
                        });

                        selectedAcademicTerm = academicTerms.length -
                            academicTerms.indexOf(dropdownSelection!);
                      },
                    ),
                  );
                } else {
                  return LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                  );
                }
              },
            ),
            if (selectedAcademicTerm != null)
              Expanded(
                child: InternalMarksTable(academicTerm: selectedAcademicTerm!),
              ),
          ],
        ),
      ),
    );
  }
}
