class Subject {
  String code;
  String name;
  bool eligible;

  Subject({
    required this.code,
    required this.name,
    required this.eligible,
  });

  @override
  String toString() => 'Subject(code: $code, name: $name, eligible: $eligible)';
}
