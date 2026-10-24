enum TaskPriority { low, medium, high }

enum TaskStatus { toDo, inProgress, done }

class TaskModel {
  final String id;
  final String title;
  final String boardName;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? assignedTo;

  TaskModel({
    required this.id,
    required this.title,
    required this.boardName,
    required this.dueDate,
    required this.priority,
    required this.status,
    this.assignedTo,
  });
}
