enum BoardRole { owner, admin, member, viewer }

class BoardModel {
  final String id;
  final String title;
  final int totalTasks;
  final String ownerId;
  final Map<String, BoardRole> membersRole;

  BoardModel({
    required this.id,
    required this.title,
    required this.totalTasks,
    required this.ownerId,
    required this.membersRole,
  });
}
