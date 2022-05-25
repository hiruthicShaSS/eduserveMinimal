class Fees {
  List<SingleFee> all = [];
  double totalDues;
  double advance;

  Fees({
    required this.totalDues,
    required this.advance,
  });

  void set add(SingleFee fee) => all.add(fee);

  int get length => all.length;

  List<String> get ids => all.map((fee) => fee.recieptNo).toList();
  List<SingleFee> get values => all;
}

class SingleFee {
  String description;
  String semester;
  double toPay;
  DateTime lastDate;
  String currency;
  double paid;
  String recieptNo;
  DateTime dateOfPayment;
  double netDues;

  SingleFee({
    required this.description,
    required this.semester,
    required this.toPay,
    required this.lastDate,
    required this.currency,
    required this.paid,
    required this.recieptNo,
    required this.dateOfPayment,
    required this.netDues,
  });

  @override
  String toString() {
    return 'SingleFee(description: $description, semester: $semester, toPay: $toPay, lastDate: $lastDate, currency: $currency, paid: $paid, recieptNo: $recieptNo, dateOfPayment: $dateOfPayment, netDues: $netDues)';
  }
}
