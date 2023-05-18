class Link {
  final String url;
  final DateTime date;
  final String uid;
  bool sentByMe;

  Link({
    required this.url,
    required this.date,
    required this.uid,
    this.sentByMe = false,
  });
}
