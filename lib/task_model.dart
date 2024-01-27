// task_model.dart
class Task {
  String id;
  String title;
  String description;
  DateTime createdAt;
  String image;
  String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.image,
    required this.status,
  });
}
