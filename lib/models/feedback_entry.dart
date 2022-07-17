class FeedbackEntry {
  String hour;
  String subject;
  String faculty;
  String topic;
  int rating;
  bool classHandled;

  String htmlId;

  FeedbackEntry({
    required this.hour,
    required this.subject,
    required this.faculty,
    required this.topic,
    required this.rating,
    required this.htmlId,
    this.classHandled = true,
  });

  @override
  String toString() {
    return 'FeedbackEntry(hour: $hour, subject: $subject, faculty: $faculty, topic: $topic, rating: $rating, classHandled: $classHandled, htmlId: $htmlId)';
  }
}
