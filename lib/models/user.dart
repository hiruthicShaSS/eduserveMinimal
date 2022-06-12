// 🎯 Dart imports:
import 'dart:convert';
import 'dart:typed_data';

class User {
  int semester;
  int arrears;
  double attendance;
  double assemblyAttendance;
  double cgpa;
  double sgpa;
  double credits;
  double nonAcademicCredits;
  String? registerNumber;
  String? kmail;
  String? name;
  String? mobile;
  String? programme;
  String? mentor;
  String? resultOf;
  Uint8List? image;
  Uint8List? qrCode;

  User({
    required this.registerNumber,
    required this.kmail,
    required this.name,
    required this.mobile,
    required this.programme,
    required this.mentor,
    required this.semester,
    required this.attendance,
    required this.assemblyAttendance,
    required this.cgpa,
    required this.sgpa,
    required this.arrears,
    required this.resultOf,
    required this.credits,
    required this.nonAcademicCredits,
    this.image,
    this.qrCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'registerNumber': registerNumber,
      'kmail': kmail,
      'name': name,
      'mobile': mobile,
      'programme': programme,
      'mentor': mentor,
      'semester': semester,
      'attendance': attendance,
      'assemblyAttendance': assemblyAttendance,
      'cgpa': cgpa,
      'sgpa': sgpa,
      'arrears': arrears,
      'resultOf': resultOf,
      'credits': credits,
      'nonAcademicCredits': nonAcademicCredits,
      'image': jsonEncode(image),
      'qrCode': jsonEncode(qrCode),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      registerNumber: map['registerNumber'],
      kmail: map['kmail'],
      name: map['name'],
      mobile: map['mobile'],
      programme: map['programme'],
      mentor: map['mentor'],
      semester: map['semester'],
      attendance: map['attendance']?.toDouble(),
      assemblyAttendance: map['assemblyAttendance']?.toDouble(),
      cgpa: map['cgpa']?.toDouble(),
      sgpa: map['sgpa']?.toDouble(),
      arrears: map['arrears']?.toInt(),
      resultOf: map['resultOf'],
      credits: map['credits']?.toDouble(),
      nonAcademicCredits: map['nonAcademicCredits']?.toDouble(),
      image: map['image'] != null
          ? Uint8List.fromList(List<int>.from(jsonDecode(map['image'])))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(registerNumber: $registerNumber, kmail: $kmail, name: $name, mobile: $mobile, programme: $programme, mentor: $mentor, semester: $semester, attendance: $attendance, assemblyAttendance: $assemblyAttendance, cgpa: $cgpa, sgpa: $sgpa, arrears: $arrears, resultOf: $resultOf, credits: $credits, nonAcademicCredits: $nonAcademicCredits, image: $image, qrCode: $qrCode)';
  }
}
