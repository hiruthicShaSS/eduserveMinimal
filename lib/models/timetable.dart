import 'dart:convert';

class TimeTable {
  String day;
  String hour1;
  String hour2;
  String hour3;
  String hour4;
  String hour5;
  String hour6;
  String hour7;
  String hour8;
  String hour9;
  String hour10;
  String hour11;

  TimeTable({
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

  @override
  String toString() {
    return 'Timetable(day: $day, hour1: $hour1, hour2: $hour2, hour3: $hour3, hour4: $hour4, hour5: $hour5, hour6: $hour6, hour7: $hour7, hour8: $hour8, hour9: $hour9, hour10: $hour10, hour11: $hour11)';
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'day': day});
    result.addAll({'hour1': hour1});
    result.addAll({'hour2': hour2});
    result.addAll({'hour3': hour3});
    result.addAll({'hour4': hour4});
    result.addAll({'hour5': hour5});
    result.addAll({'hour6': hour6});
    result.addAll({'hour7': hour7});
    result.addAll({'hour8': hour8});
    result.addAll({'hour9': hour9});
    result.addAll({'hour10': hour10});
    result.addAll({'hour11': hour11});

    return result;
  }

  factory TimeTable.fromMap(Map<String, dynamic> map) {
    return TimeTable(
      day: map['day'] ?? '',
      hour1: map['hour1'] ?? '',
      hour2: map['hour2'] ?? '',
      hour3: map['hour3'] ?? '',
      hour4: map['hour4'] ?? '',
      hour5: map['hour5'] ?? '',
      hour6: map['hour6'] ?? '',
      hour7: map['hour7'] ?? '',
      hour8: map['hour8'] ?? '',
      hour9: map['hour9'] ?? '',
      hour10: map['hour10'] ?? '',
      hour11: map['hour11'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeTable.fromJson(String source) =>
      TimeTable.fromMap(json.decode(source));
}
