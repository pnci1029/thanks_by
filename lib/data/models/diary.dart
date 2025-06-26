class Diary {
  final int? id;
  final DateTime date;
  final List<String> lines; // 3줄
  final String emotionTag;

  Diary({
    this.id,
    required this.date,
    required this.lines,
    required this.emotionTag,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().substring(0, 10),
      'line1': lines[0],
      'line2': lines[1],
      'line3': lines[2],
      'emotionTag': emotionTag,
    };
  }

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'],
      date: DateTime.parse(map['date']),
      lines: [map['line1'], map['line2'], map['line3']],
      emotionTag: map['emotionTag'],
    );
  }
}