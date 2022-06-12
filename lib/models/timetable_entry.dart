// 🎯 Dart imports:
import 'dart:convert';

class TimeTableEntry {
  String day;
  TimeTableSubject hour1;
  TimeTableSubject hour2;
  TimeTableSubject hour3;
  TimeTableSubject hour4;
  TimeTableSubject hour5;
  TimeTableSubject hour6;
  TimeTableSubject hour7;
  TimeTableSubject hour8;
  TimeTableSubject hour9;
  TimeTableSubject hour10;
  TimeTableSubject hour11;

  TimeTableEntry({
    required this.day,
    required this.hour1,
    required this.hour2,
    required this.hour3,
    required this.hour4,
    required this.hour5,
    required this.hour6,
    required this.hour7,
    required this.hour8,
    required this.hour9,
    required this.hour10,
    required this.hour11,
  });

  List<TimeTableSubject> toList() => [
        hour1,
        hour2,
        hour3,
        hour4,
        hour5,
        hour6,
        hour7,
        hour7,
        hour8,
        hour9,
        hour10,
        hour11
      ];

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'day': day});
    result.addAll({'hour1': hour1.toMap()});
    result.addAll({'hour2': hour2.toMap()});
    result.addAll({'hour3': hour3.toMap()});
    result.addAll({'hour4': hour4.toMap()});
    result.addAll({'hour5': hour5.toMap()});
    result.addAll({'hour6': hour6.toMap()});
    result.addAll({'hour7': hour7.toMap()});
    result.addAll({'hour8': hour8.toMap()});
    result.addAll({'hour9': hour9.toMap()});
    result.addAll({'hour10': hour10.toMap()});
    result.addAll({'hour11': hour11.toMap()});

    return result;
  }

  factory TimeTableEntry.fromMap(Map<String, dynamic> map) {
    return TimeTableEntry(
      day: map['day'] ?? '',
      hour1: TimeTableSubject.fromMap(map["hour1"]),
      hour2: TimeTableSubject.fromMap(map["hour2"]),
      hour3: TimeTableSubject.fromMap(map["hour3"]),
      hour4: TimeTableSubject.fromMap(map["hour4"]),
      hour5: TimeTableSubject.fromMap(map["hour5"]),
      hour6: TimeTableSubject.fromMap(map["hour6"]),
      hour7: TimeTableSubject.fromMap(map["hour7"]),
      hour8: TimeTableSubject.fromMap(map["hour8"]),
      hour9: TimeTableSubject.fromMap(map["hour9"]),
      hour10: TimeTableSubject.fromMap(map["hour10"]),
      hour11: TimeTableSubject.fromMap(map["hour11"]),
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeTableEntry.fromJson(String source) =>
      TimeTableEntry.fromMap(json.decode(source));
}

class TimeTableSubject {
  String code;
  String name;
  int batch;
  String venue;

  TimeTableSubject({
    required this.code,
    required this.name,
    required this.batch,
    required this.venue,
  });

  factory TimeTableSubject.fromString(String string) {
    String code = string.split(" ").first;
    String venue = string.split(" - ").last;

    RegExp batchExp = RegExp(r"Batch\s\d");
    String? batchString =
        batchExp.firstMatch(string)?.group(0)?.replaceAll("Batch ", "");

    int batch = int.parse(batchString ?? "0");

    String name = string.replaceAll(code, "");
    name = name.replaceAll("  ", " ");
    name = name.replaceAll(" - $venue", "");
    name = name.replaceAll("Batch $batch", "");

    return TimeTableSubject(
      code: code.trim(),
      name: name.trim(),
      batch: batch,
      venue: venue.trim(),
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'code': code});
    result.addAll({'name': name});
    result.addAll({'batch': batch});
    result.addAll({'venue': venue});

    return result;
  }

  factory TimeTableSubject.fromMap(Map<String, dynamic> map) {
    return TimeTableSubject(
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      batch: map['batch']?.toInt() ?? 0,
      venue: map['venue'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeTableSubject.fromJson(String source) =>
      TimeTableSubject.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TimeTableSubject(code: $code, name: $name, batch: $batch, venue: $venue)';
  }
}
