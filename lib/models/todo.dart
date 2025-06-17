class Todo {
  String eventId;
  String description;
  bool isCompleted;
  DateTime createdAt;

  Todo({
    required this.eventId,
    required this.description,
    required this.createdAt,
    this.isCompleted = false,
  });
}
