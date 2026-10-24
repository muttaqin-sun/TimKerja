enum NotificationType { mention, assignment, deadline, comment, system }

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
    this.isRead = false, // Default notifikasi baru belum dibaca
  });
}
