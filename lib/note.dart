class Note {
  final String content;
  final String date;
  final int color;
  final String id;

  Note({this.content, this.date, this.color, this.id});

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'date': date,
      'color': color,
      'id': id,
    };
  }
}