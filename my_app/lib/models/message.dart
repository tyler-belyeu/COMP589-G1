class Message {
  final String text;
  final DateTime date;
  final String uid;
  bool sentByMe;

  Message({
    required this.text,
    required this.date,
    required this.uid,
    this.sentByMe = false,
  });
}
