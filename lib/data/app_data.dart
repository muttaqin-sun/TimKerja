import 'package:flutter/material.dart';

class AppDataController extends ChangeNotifier {
  static final AppDataController instance = AppDataController._internal();
  AppDataController._internal();

  String currentUserRole = 'Pembuat Board';
  Map<String, dynamic> currentUserProfile = {
    'name': 'Ilham',
    'email': 'ilham@student.ac.id',
    'initials': 'IM',
    'avatarColor': 0xFF0F766E,
  };

  List<Map<String, dynamic>> boards = [
    {
      'id': 'b1',
      'title': 'Kuliah - TI',
      'desc': 'Proyek tugas pemrograman & UI/UX',
      'color': 0xFF004D40,
      'privacy': 'Private',
      'code': 'KULIAH-TI-8X2P',
      'lists': ['Tugas Harian', 'Projek Akhir', 'Revisi'],
      'lockedLists': <String>[],
      'members': [
        {'name': 'Ilham', 'color': 0xFF0F766E},
        {'name': 'Sari', 'color': 0xFF3B82F6},
        {'name': 'Budi', 'color': 0xFF10B981},
      ],
    },
    {
      'id': 'b2',
      'title': 'Project A',
      'desc': 'Manajemen proyek utama',
      'color': 0xFF16A34A,
      'privacy': 'Workspace',
      'code': 'PROJ-A-9Y3Q',
      'lists': ['Tahap 1', 'Tahap 2', 'Selesai'],
      'lockedLists': <String>['Selesai'],
      'members': [
        {'name': 'Ilham', 'color': 0xFF0F766E},
        {'name': 'Andi', 'color': 0xFFF59E0B},
      ],
    },
  ];

  List<Map<String, dynamic>> tasks = [
    {
      'id': 't1',
      'boardId': 'b1',
      'listName': 'Tugas Harian',
      'title': 'Tugas UI/UX - Wireframe',
      'status': 'In Progress',
      'priority': 'High',
      'date': 'Today',
      'desc': 'Buat rancangan wireframe low-fidelity.',
      'isDone': false,
      'coverColor': null,
      'coverSize': 'header',
      'startDate': '25 Okt',
      'startTime': '08.00',
      'dueDate': '26 Okt',
      'dueTime': '23.59',
      'reminder': '1 hari sebelumnya',
      'addMeToCard': true,
      'subtasks': [
        {'title': 'Login Screen', 'isDone': true},
        {'title': 'Home Screen', 'isDone': false},
      ],
      'comments': [
        {
          'author': 'Sari',
          'text': 'Mohon disesuaikan dengan panduan warna utama ya.',
          'time': '10:15',
        },
      ],
      'attachments': [
        {'name': 'LandingPage.fig', 'icon': Icons.image_rounded},
        {'name': 'Desain-UI.pdf', 'icon': Icons.picture_as_pdf_rounded},
        {'name': 'Referensi.png', 'icon': Icons.image_rounded},
      ],
      'members': [
        {'name': 'Ilham', 'color': 0xFF0F766E},
        {'name': 'Sari', 'color': 0xFF3B82F6},
      ],
    },
    {
      'id': 't2',
      'boardId': 'b1',
      'listName': 'Projek Akhir',
      'title': 'Baca Jurnal',
      'status': 'To Do',
      'priority': 'Low',
      'date': 'Tomorrow',
      'desc': '',
      'isDone': false,
      'coverColor': null,
      'coverSize': 'header',
      'startDate': null,
      'startTime': null,
      'dueDate': null,
      'dueTime': null,
      'reminder': '1 hari sebelumnya',
      'addMeToCard': false,
      'subtasks': <Map<String, dynamic>>[],
      'comments': <Map<String, dynamic>>[],
      'attachments': <Map<String, dynamic>>[],
      'members': [
        {'name': 'Ilham', 'color': 0xFF0F766E},
      ],
    },
  ];

  List<Map<String, dynamic>> notifications = [
    {
      'id': 'n1',
      'icon': Icons.error_outline_rounded,
      'title': 'Deadline tugas hampir habis',
      'subtitle': 'Implementasi API • Project A\nDeadline tugas tersisa 2 jam. Segera selesaikan.',
      'time': '5 menit lalu',
      'priority': 'High',
      'type': 'Due Dates',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'isRead': false,
    },
    {
      'id': 'n2',
      'icon': Icons.access_time_rounded,
      'title': 'Tugas perlu segera diperiksa',
      'subtitle': 'Revisi Desain • Kuliah - TI\nTugas menunggu pemeriksaan.',
      'time': '30 menit lalu',
      'priority': 'Medium',
      'type': 'Assignments',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': false,
    },
    {
      'id': 'n3',
      'icon': Icons.alternate_email_rounded,
      'title': 'Sari menyebut Anda dalam komentar',
      'subtitle': 'Tugas UI/UX - Wireframe • Kuliah - TI\n"@Ilham, tolong cek desain terbarunya ya."',
      'time': '1 jam lalu',
      'priority': 'Low',
      'type': 'Mentions',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'isRead': true,
    },
  ];

  List<Map<String, dynamic>> recentActivities = [
    {'id': 'a1', 'title': 'Andi assigned you to Tugas UI/UX', 'time': '2h ago'},
    {'id': 'a2', 'title': 'Sari commented on Project A', 'time': '4h ago'},
  ];

  // Getter Cerdas untuk Today's Tasks
  List<Map<String, dynamic>> get todayTasks {
    return tasks
        .where(
          (t) =>
              t['date'] == 'Today' ||
              t['dueDate'] == 'Hari ini' ||
              t['dueDate'] == 'Today',
        )
        .toList();
  }

  // ==========================================
  // FITUR BARU: AUTO LOG RECENT ACTIVITY
  // ==========================================
  void logActivity(String title) {
    recentActivities.insert(0, {
      'id': 'act_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'time': 'Baru saja',
    });
    if (recentActivities.length > 10) {
      recentActivities.removeLast(); // Maksimal 10 log tersimpan
    }
    notifyListeners();
  }

  // ==========================================
  // FITUR BARU: CRUD NOTIFICATIONS
  // ==========================================
  void markNotificationAsRead(String notifId) {
    final notif = notifications.firstWhere(
      (n) => n['id'] == notifId,
      orElse: () => {},
    );
    if (notif.isNotEmpty && notif['isRead'] == false) {
      notif['isRead'] = true;
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    bool isChanged = false;
    for (var notif in notifications) {
      if (notif['isRead'] == false) {
        notif['isRead'] = true;
        isChanged = true;
      }
    }
    if (isChanged) notifyListeners();
  }

  void deleteNotification(String notifId) {
    notifications.removeWhere((n) => n['id'] == notifId);
    notifyListeners();
  }

  // ==========================================
  // METHODS LAINNYA
  // ==========================================

  void addBoard(
    String title,
    String desc,
    dynamic color,
    String privacy, {
    List<String>? initialLists,
  }) {
    String generateCode() {
      return 'BRD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }

    boards.add({
      'id': 'b_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'desc': desc,
      'color': color is Color ? color.value : color,
      'privacy': privacy,
      'code': generateCode(),
      'lists': initialLists ?? <String>[],
      'lockedLists': <String>[],
      'members': [
        {
          'name': currentUserProfile['name'],
          'color': currentUserProfile['avatarColor'],
        },
      ],
    });

    logActivity('Membuat board baru: "$title"'); // Auto Log
    notifyListeners();
  }

  bool joinBoardByCode(String code) {
    final boardIndex = boards.indexWhere(
      (b) => b['code'] == code.trim().toUpperCase(),
    );
    if (boardIndex != -1) {
      final board = boards[boardIndex];
      List<dynamic> members = List.from(board['members'] ?? []);
      bool alreadyJoined = members.any(
        (m) => m['name'] == currentUserProfile['name'],
      );

      if (!alreadyJoined) {
        members.add({
          'name': currentUserProfile['name'],
          'color': currentUserProfile['avatarColor'],
        });
        board['members'] = members;

        logActivity('Bergabung ke board: "${board['title']}"'); // Auto Log
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void updateBoardSettings(
    String boardId,
    String newTitle,
    String newDesc,
    String newPrivacy,
  ) {
    final board = boards.firstWhere(
      (b) => b['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      board['title'] = newTitle;
      board['desc'] = newDesc;
      board['privacy'] = newPrivacy;
      logActivity('Mengubah pengaturan board: "$newTitle"');
      notifyListeners();
    }
  }

  void addBoardList(String boardId, String listTitle) {
    final board = boards.firstWhere(
      (b) => b['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final List<String> currentLists = List<String>.from(board['lists'] ?? []);
      if (!currentLists.contains(listTitle)) {
        currentLists.add(listTitle);
        board['lists'] = currentLists;
        notifyListeners();
      }
    }
  }

  void renameBoardList(String boardId, String oldName, String newName) {
    final board = boards.firstWhere(
      (b) => b['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final List<String> currentLists = List<String>.from(board['lists'] ?? []);
      final int index = currentLists.indexOf(oldName);

      if (index != -1 &&
          !currentLists.contains(newName) &&
          newName.isNotEmpty) {
        currentLists[index] = newName;
        board['lists'] = currentLists;
        board['lockedLists'] ??= <String>[];
        List<String> lockedLists = List<String>.from(board['lockedLists']);
        if (lockedLists.contains(oldName)) {
          lockedLists.remove(oldName);
          lockedLists.add(newName);
          board['lockedLists'] = lockedLists;
        }
        for (var task in tasks) {
          if (task['boardId'] == boardId && task['listName'] == oldName) {
            task['listName'] = newName;
          }
        }
        notifyListeners();
      }
    }
  }

  void deleteBoardList(String boardId, String listName) {
    final board = boards.firstWhere(
      (b) => b['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final List<String> currentLists = List<String>.from(board['lists'] ?? []);
      currentLists.remove(listName);
      board['lists'] = currentLists;
      board['lockedLists'] ??= <String>[];
      List<String> lockedLists = List<String>.from(board['lockedLists']);
      lockedLists.remove(listName);
      board['lockedLists'] = lockedLists;
      tasks.removeWhere(
        (t) => t['boardId'] == boardId && t['listName'] == listName,
      );
      notifyListeners();
    }
  }

  void toggleListLock(String boardId, String listName) {
    final board = boards.firstWhere(
      (b) => b['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      board['lockedLists'] ??= <String>[];
      List<String> lockedLists = List<String>.from(board['lockedLists']);
      if (lockedLists.contains(listName)) {
        lockedLists.remove(listName);
      } else {
        lockedLists.add(listName);
      }
      board['lockedLists'] = lockedLists;
      notifyListeners();
    }
  }

  void sortTasksByStatus(String boardId, String listName) {
    List<Map<String, dynamic>> targetTasks = tasks
        .where((t) => t['boardId'] == boardId && t['listName'] == listName)
        .toList();
    targetTasks.sort((a, b) {
      bool aDone = a['isDone'] ?? false;
      bool bDone = b['isDone'] ?? false;
      if (aDone != bDone) return aDone ? 1 : -1;
      String aTitle = a['title'] ?? '';
      String bTitle = b['title'] ?? '';
      return aTitle.toLowerCase().compareTo(bTitle.toLowerCase());
    });
    tasks.removeWhere(
      (t) => t['boardId'] == boardId && t['listName'] == listName,
    );
    tasks.addAll(targetTasks);
    notifyListeners();
  }

  void moveTaskToList(
    String taskId,
    String targetListName, {
    int? targetIndex,
  }) {
    final taskIndex = tasks.indexWhere((t) => t['id'] == taskId);
    if (taskIndex != -1) {
      final task = Map<String, dynamic>.from(tasks[taskIndex]);
      final String oldList = task['listName'];
      task['listName'] = targetListName;

      tasks.removeAt(taskIndex);

      if (targetIndex != null) {
        // Cari index aktual di list `tasks` global yang sesuai targetIndex di targetListName
        int currentCountInTarget = 0;
        int insertPos = tasks.length;
        for (int i = 0; i < tasks.length; i++) {
          if (tasks[i]['boardId'] == task['boardId'] &&
              tasks[i]['listName'] == targetListName) {
            if (currentCountInTarget == targetIndex) {
              insertPos = i;
              break;
            }
            currentCountInTarget++;
          }
        }
        tasks.insert(insertPos, task);
      } else {
        tasks.add(task);
      }

      if (oldList != targetListName) {
        logActivity('Memindahkan tugas "${task['title']}" ke $targetListName');
      }
      notifyListeners();
    }
  }

  void addTask(String boardId, String title, String listName) {
    tasks.add({
      'id': 't_${DateTime.now().millisecondsSinceEpoch}',
      'boardId': boardId,
      'listName': listName,
      'title': title,
      'status': 'To Do',
      'priority': 'Low',
      'date': 'No Date',
      'desc': '',
      'isDone': false,
      'coverColor': null,
      'coverSize': 'header',
      'startDate': null,
      'startTime': null,
      'dueDate': null,
      'dueTime': null,
      'reminder': '1 hari sebelumnya',
      'addMeToCard': false,
      'subtasks': <Map<String, dynamic>>[],
      'comments': <Map<String, dynamic>>[],
      'attachments': <Map<String, dynamic>>[],
      'members': <Map<String, dynamic>>[],
    });

    logActivity('Menambahkan tugas: "$title"'); // Auto Log
    notifyListeners();
  }

  void updateTaskDesc(String taskId, String newDesc) {
    final task = tasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
    if (task.isNotEmpty) {
      task['desc'] = newDesc;
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String taskId) {
    final task = tasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
    if (task.isNotEmpty) {
      bool currentVal = task['isDone'] as bool;
      task['isDone'] = !currentVal;
      task['status'] = task['isDone'] ? 'Done' : 'To Do';

      // Auto Log
      logActivity(
        task['isDone']
            ? 'Menyelesaikan tugas: "${task['title']}"'
            : 'Membuka kembali tugas: "${task['title']}"',
      );
      notifyListeners();
    }
  }

  void _updateTaskStatus(Map<String, dynamic> task) {
    final subtasks = task['subtasks'] as List;
    if (subtasks.isEmpty) {
      task['status'] = 'To Do';
      task['isDone'] = false;
      return;
    }
    final completedCount = subtasks.where((s) => s['isDone'] == true).length;
    if (completedCount == 0) {
      task['status'] = 'To Do';
      task['isDone'] = false;
    } else if (completedCount < subtasks.length) {
      task['status'] = 'In Progress';
      task['isDone'] = false;
    } else {
      task['status'] = 'Done';
      task['isDone'] = true;
    }
  }

  void addSubtask(String taskId, String title) {
    final task = tasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
    if (task.isNotEmpty) {
      (task['subtasks'] as List).add({'title': title, 'isDone': false});
      _updateTaskStatus(task);
      notifyListeners();
    }
  }

  void toggleSubtask(String taskId, int index) {
    final task = tasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
    if (task.isNotEmpty) {
      final subtasks = task['subtasks'] as List;
      if (index >= 0 && index < subtasks.length) {
        subtasks[index]['isDone'] = !subtasks[index]['isDone'];
        _updateTaskStatus(task);
        notifyListeners();
      }
    }
  }

  void setTaskCover(String taskId, Color? color, {String size = 'header'}) {
    final task = tasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
    if (task.isNotEmpty) {
      task['coverColor'] = color?.value;
      task['coverSize'] = size;
      notifyListeners();
    }
  }

  void reorderBoardLists(String boardId, int oldIndex, int newIndex) {
    final board = boards.firstWhere((b) => b['id'] == boardId, orElse: () => {});
    if (board.isNotEmpty) {
      final List<String> currentLists = List<String>.from(board['lists'] ?? []);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = currentLists.removeAt(oldIndex);
      currentLists.insert(newIndex, item);
      board['lists'] = currentLists;
      notifyListeners();
    }
  }

  void addPoll(String boardId, String question, List<String> options) {
    final board = boards.firstWhere((b) => b['id'] == boardId, orElse: () => {});
    if (board.isNotEmpty) {
      board['polls'] ??= <Map<String, dynamic>>[];
      (board['polls'] as List).add({
        'id': 'poll_${DateTime.now().millisecondsSinceEpoch}',
        'question': question,
        'creator': currentUserProfile['name'] ?? 'Pengguna',
        'createdAt': 'Hari ini',
        'isClosed': false,
        'options': options.map((opt) => {'text': opt, 'votes': <String>[]}).toList(),
      });
      logActivity('Membuat polling baru: "$question"');
      notifyListeners();
    }
  }

  void votePoll(String boardId, String pollId, int optionIndex) {
    final board = boards.firstWhere((b) => b['id'] == boardId, orElse: () => {});
    if (board.isNotEmpty && board['polls'] != null) {
      final userName = currentUserProfile['name'] ?? 'Pengguna';
      for (var poll in (board['polls'] as List)) {
        if (poll['id'] == pollId && poll['isClosed'] != true) {
          final options = poll['options'] as List;
          // Cek apakah user sudah vote opsi lain di poll yang sama, jika ya hilangkan (single choice vote)
          for (var opt in options) {
            (opt['votes'] as List).remove(userName);
          }
          if (optionIndex >= 0 && optionIndex < options.length) {
            (options[optionIndex]['votes'] as List).add(userName);
          }
          notifyListeners();
          break;
        }
      }
    }
  }

  void togglePollStatus(String boardId, String pollId) {
    final board = boards.firstWhere((b) => b['id'] == boardId, orElse: () => {});
    if (board.isNotEmpty && board['polls'] != null) {
      for (var poll in (board['polls'] as List)) {
        if (poll['id'] == pollId) {
          poll['isClosed'] = !(poll['isClosed'] ?? false);
          notifyListeners();
          break;
        }
      }
    }
  }

  void deletePoll(String boardId, String pollId) {
    final board = boards.firstWhere((b) => b['id'] == boardId, orElse: () => {});
    if (board.isNotEmpty && board['polls'] != null) {
      (board['polls'] as List).removeWhere((p) => p['id'] == pollId);
      notifyListeners();
    }
  }

  void updateBoardDetails(String boardId, {String? title, String? desc, int? color, String? privacy}) {
    final board = boards.firstWhere((b) => b['id'] == boardId, orElse: () => {});
    if (board.isNotEmpty) {
      if (title != null && title.trim().isNotEmpty) board['title'] = title.trim();
      if (desc != null) board['desc'] = desc.trim();
      if (color != null) board['color'] = color;
      if (privacy != null) board['privacy'] = privacy;
      logActivity('Memperbarui informasi board "${board['title']}"');
      notifyListeners();
    }
  }

  void addBoardMember(String boardId, String name, {int? color}) {
    final board = boards.firstWhere((b) => b['id'] == boardId, orElse: () => {});
    if (board.isNotEmpty) {
      board['members'] ??= <Map<String, dynamic>>[];
      final List members = board['members'];
      final bool alreadyExists = members.any((m) => (m['name'] as String).toLowerCase() == name.trim().toLowerCase());
      if (!alreadyExists && name.trim().isNotEmpty) {
        final colors = [0xFF0F766E, 0xFF3B82F6, 0xFF10B981, 0xFFF59E0B, 0xFF8B5CF6, 0xFFEF4444];
        final pickedColor = color ?? colors[members.length % colors.length];
        members.add({
          'name': name.trim(),
          'color': pickedColor,
        });
        logActivity('Menambahkan anggota "$name" ke board');
        notifyListeners();
      }
    }
  }

  void removeBoardMember(String boardId, String memberName) {
    final board = boards.firstWhere((b) => b['id'] == boardId, orElse: () => {});
    if (board.isNotEmpty && board['members'] != null) {
      (board['members'] as List).removeWhere((m) => m['name'] == memberName);
      logActivity('Mengeluarkan anggota "$memberName" dari board');
      notifyListeners();
    }
  }

  void addBoardFile(String boardId, String fileName, String size, {String extension = 'file'}) {
    final board = boards.firstWhere((b) => b['id'] == boardId, orElse: () => {});
    if (board.isNotEmpty) {
      board['files'] ??= <Map<String, dynamic>>[];
      (board['files'] as List).add({
        'id': 'file_${DateTime.now().millisecondsSinceEpoch}',
        'name': fileName,
        'size': size,
        'uploadedBy': currentUserProfile['name'] ?? 'Pengguna',
        'uploadedAt': 'Hari ini',
        'extension': extension,
      });
      logActivity('Mengunggah berkas "$fileName" ke board');
      notifyListeners();
    }
  }

  void deleteBoardFile(String boardId, String fileId) {
    final board = boards.firstWhere((b) => b['id'] == boardId, orElse: () => {});
    if (board.isNotEmpty && board['files'] != null) {
      (board['files'] as List).removeWhere((f) => f['id'] == fileId);
      notifyListeners();
    }
  }

  void deleteBoard(String boardId) {
    boards.removeWhere((b) => b['id'] == boardId);
    tasks.removeWhere((t) => t['boardId'] == boardId);
    logActivity('Menghapus board proyek');
    notifyListeners();
  }

  void addComment(String taskId, String text) {
    final task = tasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
    if (task.isNotEmpty) {
      (task['comments'] as List).add({
        'author': currentUserProfile['name'],
        'text': text,
        'time': 'Baru saja',
      });

      logActivity('Mengomentari tugas: "${task['title']}"'); // Auto Log
      notifyListeners();
    }
  }

  void setTaskStartDate(String taskId, String date, String time) {
    final task = tasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
    if (task.isNotEmpty) {
      task['startDate'] = date;
      task['startTime'] = time;
      notifyListeners();
    }
  }

  void setTaskDueDate(
    String taskId,
    String date,
    String time,
    String reminder,
    bool addMeToCard,
  ) {
    final task = tasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
    if (task.isNotEmpty) {
      task['dueDate'] = date;
      task['dueTime'] = time;
      task['reminder'] = reminder;
      task['addMeToCard'] = addMeToCard;

      if (date != 'Tanggal') {
        task['date'] = date;
      }
      notifyListeners();
    }
  }
}
