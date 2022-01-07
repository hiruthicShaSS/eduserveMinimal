import 'dart:convert';

class Currency {
  static String inr = "\u{20B9}";

  static Map<String, dynamic> currencyCharMap = {
    "Indian Rupee": inr,
  };

  static String currencyToChar(String currency) => currencyCharMap[currency];
}

class Fees {
  List<SingleFee> all = [];
  List dues = [];

  void add(String id, List<String> data) {
    all.add(SingleFee(
      reciept: data[1],
      recieptType: data[2],
      description: data[0],
      date: data[2],
      amountPaid: double.parse(data[5]),
      currency: Currency.currencyToChar(data[4]),
    ));
  }

  int get length => all.length;

  List<String> get ids => all.map((fee) => fee.reciept).toList();
  List<SingleFee> get values => all;
}

class SingleFee {
  String reciept;
  String recieptType;
  String description;
  String date;
  double amountPaid;
  String currency;

  SingleFee({
    required this.reciept,
    required this.recieptType,
    required this.description,
    required this.date,
    required this.amountPaid,
    required this.currency,
  });

  SingleFee copyWith({
    String? reciept,
    String? recieptType,
    String? description,
    String? date,
    double? amountPaid,
  }) {
    return SingleFee(
        reciept: reciept ?? this.reciept,
        recieptType: recieptType ?? this.recieptType,
        description: description ?? this.description,
        date: date ?? this.date,
        amountPaid: amountPaid ?? this.amountPaid,
        currency: Currency.currencyToChar("Indian Rupee"));
  }

  Map<String, dynamic> toMap() {
    return {
      'reciept': reciept,
      'recieptType': recieptType,
      'description': description,
      'date': date,
      'amountPaid': amountPaid,
    };
  }

  factory SingleFee.fromMap(Map<String, dynamic> map) {
    return SingleFee(
        reciept: map['reciept'] ?? '',
        recieptType: map['recieptType'] ?? '',
        description: map['description'] ?? '',
        date: map['date'] ?? '',
        amountPaid: map['amountPaid']?.toDouble() ?? 0.0,
        currency: Currency.currencyToChar("Indian Rupee"));
  }

  String toJson() => json.encode(toMap());

  factory SingleFee.fromJson(String source) =>
      SingleFee.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SingleFee(reciept: $reciept, recieptType: $recieptType, description: $description, date: $date, amountPaid: $amountPaid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SingleFee &&
        other.reciept == reciept &&
        other.recieptType == recieptType &&
        other.description == description &&
        other.date == date &&
        other.amountPaid == amountPaid;
  }

  @override
  int get hashCode {
    return reciept.hashCode ^
        recieptType.hashCode ^
        description.hashCode ^
        date.hashCode ^
        amountPaid.hashCode;
  }
}
