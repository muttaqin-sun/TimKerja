import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../services/board_service.dart';

class AppDataController extends ChangeNotifier {
  static final AppDataController instance = AppDataController._internal();
  AppDataController._internal();

  String currentUserRole =
      'Anggota'; // Default awal, akan di-update oleh Supabase

  // 1. UBAH PROFIL MENJADI BLUEPRINT KOSONG
  Map currentUserProfile = {
    'id': '',
    'name': 'Loading...',
    'email': 'Loading...',
    'initials': '?',
    'avatarColor': 0xFF0F766E,
    'avatarUrl': null,
  };

  // 2. TAMBAHKAN FUNGSI UNTUK FETCH PROFIL DARI SUPABASE
  Future<void> loadUserProfile(String userId) async {
    final profileData = await ProfileService.getProfile(userId);

    if (profileData != null) {
      currentUserProfile = {
        'id': profileData['id'],
        'name': profileData['name'] ?? 'User',
        'email': profileData['email'] ?? '',
        'initials': _getInitials(profileData['name'] ?? 'U'),
        'avatarColor': profileData['avatar_color'] ?? 0xFF0F766E,
        'avatarUrl': profileData['avatar_url'],
      };

      currentUserRole = profileData['role'] ?? 'Anggota';
      notifyListeners();
    }
  }

  // Update data profil lokal secara langsung
  void updateLocalProfile({String? name, String? avatarUrl}) {
    if (name != null) {
      currentUserProfile['name'] = name;
      currentUserProfile['initials'] = _getInitials(name);
    }
    if (avatarUrl != null) {
      currentUserProfile['avatarUrl'] = avatarUrl;
    }
    notifyListeners();
  }

  // Reset data user saat logout
  void resetUserSession() {
    currentUserRole = 'Anggota';
    currentUserProfile = {
      'id': '',
      'name': 'Loading...',
      'email': 'Loading...',
      'initials': '?',
      'avatarColor': 0xFF0F766E,
      'avatarUrl': null,
    };
    boards = [];
    tasks = [];
    notifyListeners();
  }

  // Load Boards dari Supabase
  Future<void> loadUserBoards(String userId) async {
    final fetched = await BoardService.fetchUserBoards(
      userId: userId,
      role: currentUserRole,
    );

    boards = fetched.map((b) {
      // Normalisasi format board agar kompatibel dengan UI Timkerja yang sudah ada
      final List rawLists = b['board_lists'] as List? ?? [];
      rawLists.sort((a, b) => (a['position'] ?? 0).compareTo(b['position'] ?? 0));
      final List<String> listTitles = rawLists.map((l) => l['title'].toString()).toList();

      final List rawMembers = b['board_members'] as List? ?? [];
      final List<Map<String, dynamic>> memberMaps = rawMembers.map((m) {
        final prof = m['profiles'] as Map? ?? {};
        return {
          'userId': m['user_id'],
          'name': prof['name'] ?? 'Member',
          'color': prof['avatar_color'] ?? 0xFF0F766E,
          'role': m['role'] ?? 'Member',
        };
      }).toList();

      return {
        'id': b['id'].toString(),
        'title': b['title'] ?? 'Untitled Board',
        'desc': b['description'] ?? '',
        'color': b['color'] ?? 0xFF004D40,
        'privacy': b['privacy'] ?? 'Private',
        'code': b['code'] ?? '',
        'created_by': b['created_by']?.toString(),
        'lists': listTitles,
        'lockedLists': [],
        'members': memberMaps,
        'polls': [],
        'files': [],
      };
    }).toList();

    notifyListeners();
  }

  // Helper pembuat inisial nama
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  List boards = [];

  List tasks = [
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
      'subtasks': [],
      'comments': [],
      'attachments': [],
      'members': [
        {'name': 'Ilham', 'color': 0xFF0F766E},
      ],
    },
  ];

  List notifications = [
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

  List recentActivities = [
    {'id': 'a1', 'title': 'Andi assigned you to Tugas UI/UX', 'time': '2h ago'},
    {'id': 'a2', 'title': 'Sari commented on Project A', 'time': '4h ago'},
  ];

  List get todayTasks {
    return tasks.where((t) {
      final taskMap = t as Map;
      return taskMap['date'] == 'Today' ||
          taskMap['dueDate'] == 'Hari ini' ||
          taskMap['dueDate'] == 'Today';
    }).toList();
  }

  void logActivity(String title) {
    recentActivities.insert(0, {
      'id': 'act_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'time': 'Baru saja',
    });
    if (recentActivities.length > 10) {
      recentActivities.removeLast();
    }
    notifyListeners();
  }

  void markNotificationAsRead(String notifId) {
    final notif = notifications.firstWhere(
      (n) => (n as Map)['id'] == notifId,
      orElse: () => {},
    );
    if (notif.isNotEmpty && (notif as Map)['isRead'] == false) {
      notif['isRead'] = true;
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    bool isChanged = false;
    for (var notif in notifications) {
      final notifMap = notif as Map;
      if (notifMap['isRead'] == false) {
        notifMap['isRead'] = true;
        isChanged = true;
      }
    }
    if (isChanged) notifyListeners();
  }

  void deleteNotification(String notifId) {
    notifications.removeWhere((n) => (n as Map)['id'] == notifId);
    notifyListeners();
  }

  Future<bool> addBoard(
    String title,
    String desc,
    dynamic color,
    String privacy, {
    List? initialLists,
  }) async {
    final userId = currentUserProfile['id'];
    if (userId == null || userId.toString().isEmpty) return false;

    final colorVal = color is Color ? color.value : (color as int? ?? 0xFF004D40);

    final newBoard = await BoardService.createBoard(
      title: title,
      desc: desc,
      color: colorVal,
      privacy: privacy,
      userId: userId.toString(),
    );

    if (newBoard != null) {
      logActivity('Membuat board baru: "$title"');
      await loadUserBoards(userId.toString());
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> joinBoardByCode(String code) async {
    final userId = currentUserProfile['id'];
    if (userId == null || userId.toString().isEmpty) {
      return {'success': false, 'message': 'User belum login.'};
    }

    final res = await BoardService.joinBoardByCode(
      code: code,
      userId: userId.toString(),
    );

    if (res['success'] == true) {
      final boardTitle = res['board']?['title'] ?? 'Board';
      logActivity('Bergabung ke board: "$boardTitle"');
      await loadUserBoards(userId.toString());
    }
    return res;
  }

  Future<bool> updateBoardSettings(
    String boardId,
    String newTitle,
    String newDesc,
    String newPrivacy,
  ) async {
    final success = await BoardService.updateBoardSettings(
      boardId: boardId,
      title: newTitle,
      desc: newDesc,
      privacy: newPrivacy,
    );

    if (success) {
      final board = boards.firstWhere(
        (b) => (b as Map)['id'] == boardId,
        orElse: () => {},
      );
      if (board.isNotEmpty) {
        final boardMap = board as Map;
        boardMap['title'] = newTitle;
        boardMap['desc'] = newDesc;
        boardMap['privacy'] = newPrivacy;
        logActivity('Mengubah pengaturan board: "$newTitle"');
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> deleteBoard(String boardId) async {
    final success = await BoardService.deleteBoard(boardId);
    if (success) {
      boards.removeWhere((b) => (b as Map)['id'] == boardId);
      tasks.removeWhere((t) => (t as Map)['boardId'] == boardId);
      logActivity('Menghapus board proyek');
      notifyListeners();
    }
    return success;
  }

  Future<bool> leaveBoard(String boardId) async {
    final userId = currentUserProfile['id'];
    if (userId == null) return false;

    final success = await BoardService.leaveBoard(
      boardId: boardId,
      userId: userId.toString(),
    );

    if (success) {
      boards.removeWhere((b) => (b as Map)['id'] == boardId);
      tasks.removeWhere((t) => (t as Map)['boardId'] == boardId);
      logActivity('Keluar dari board');
      notifyListeners();
    }
    return success;
  }

  void addBoardList(String boardId, String listTitle) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final boardMap = board as Map;
      final List currentLists = List.from(boardMap['lists'] ?? []);
      if (!currentLists.contains(listTitle)) {
        currentLists.add(listTitle);
        boardMap['lists'] = currentLists;
        notifyListeners();
      }
    }
  }

  void renameBoardList(String boardId, String oldName, String newName) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final boardMap = board as Map;
      final List currentLists = List.from(boardMap['lists'] ?? []);
      final int index = currentLists.indexOf(oldName);

      if (index != -1 &&
          !currentLists.contains(newName) &&
          newName.isNotEmpty) {
        currentLists[index] = newName;
        boardMap['lists'] = currentLists;
        boardMap['lockedLists'] ??= [];
        List lockedLists = List.from(boardMap['lockedLists']);
        if (lockedLists.contains(oldName)) {
          lockedLists.remove(oldName);
          lockedLists.add(newName);
          boardMap['lockedLists'] = lockedLists;
        }
        for (var task in tasks) {
          final taskMap = task as Map;
          if (taskMap['boardId'] == boardId && taskMap['listName'] == oldName) {
            taskMap['listName'] = newName;
          }
        }
        notifyListeners();
      }
    }
  }

  void deleteBoardList(String boardId, String listName) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final boardMap = board as Map;
      final List currentLists = List.from(boardMap['lists'] ?? []);
      currentLists.remove(listName);
      boardMap['lists'] = currentLists;
      boardMap['lockedLists'] ??= [];
      List lockedLists = List.from(boardMap['lockedLists']);
      lockedLists.remove(listName);
      boardMap['lockedLists'] = lockedLists;
      tasks.removeWhere(
        (t) => (t as Map)['boardId'] == boardId && t['listName'] == listName,
      );
      notifyListeners();
    }
  }

  void toggleListLock(String boardId, String listName) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final boardMap = board as Map;
      boardMap['lockedLists'] ??= [];
      List lockedLists = List.from(boardMap['lockedLists']);
      if (lockedLists.contains(listName)) {
        lockedLists.remove(listName);
      } else {
        lockedLists.add(listName);
      }
      boardMap['lockedLists'] = lockedLists;
      notifyListeners();
    }
  }

  void sortTasksByStatus(String boardId, String listName) {
    List targetTasks = tasks
        .where(
          (t) => (t as Map)['boardId'] == boardId && t['listName'] == listName,
        )
        .toList();
    targetTasks.sort((a, b) {
      final aMap = a as Map;
      final bMap = b as Map;
      bool aDone = aMap['isDone'] ?? false;
      bool bDone = bMap['isDone'] ?? false;
      if (aDone != bDone) return aDone ? 1 : -1;
      String aTitle = aMap['title'] ?? '';
      String bTitle = bMap['title'] ?? '';
      return aTitle.toLowerCase().compareTo(bTitle.toLowerCase());
    });
    tasks.removeWhere(
      (t) => (t as Map)['boardId'] == boardId && t['listName'] == listName,
    );
    tasks.addAll(targetTasks);
    notifyListeners();
  }

  void moveTaskToList(
    String taskId,
    String targetListName, {
    int? targetIndex,
  }) {
    final taskIndex = tasks.indexWhere((t) => (t as Map)['id'] == taskId);
    if (taskIndex != -1) {
      final task = Map.from(tasks[taskIndex] as Map);
      final String oldList = task['listName'];
      task['listName'] = targetListName;
      tasks.removeAt(taskIndex);

      if (targetIndex != null) {
        int currentCountInTarget = 0;
        int insertPos = tasks.length;
        for (int i = 0; i < tasks.length; i++) {
          final tMap = tasks[i] as Map;
          if (tMap['boardId'] == task['boardId'] &&
              tMap['listName'] == targetListName) {
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
      'subtasks': [],
      'comments': [],
      'attachments': [],
      'members': [],
    });
    logActivity('Menambahkan tugas: "$title"');
    notifyListeners();
  }

  void updateTaskDesc(String taskId, String newDesc) {
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => {},
    );
    if (task.isNotEmpty) {
      (task as Map)['desc'] = newDesc;
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String taskId) {
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => {},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      bool currentVal = taskMap['isDone'] as bool;
      taskMap['isDone'] = !currentVal;
      taskMap['status'] = taskMap['isDone'] ? 'Done' : 'To Do';
      logActivity(
        taskMap['isDone']
            ? 'Menyelesaikan tugas: "${taskMap['title']}"'
            : 'Membuka kembali tugas: "${taskMap['title']}"',
      );
      notifyListeners();
    }
  }

  void _updateTaskStatus(Map task) {
    final subtasks = task['subtasks'] as List;
    if (subtasks.isEmpty) {
      task['status'] = 'To Do';
      task['isDone'] = false;
      return;
    }
    final completedCount = subtasks
        .where((s) => (s as Map)['isDone'] == true)
        .length;
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
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => {},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      (taskMap['subtasks'] as List).add({'title': title, 'isDone': false});
      _updateTaskStatus(taskMap);
      notifyListeners();
    }
  }

  void toggleSubtask(String taskId, int index) {
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => {},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      final subtasks = taskMap['subtasks'] as List;
      if (index >= 0 && index < subtasks.length) {
        final subtaskMap = subtasks[index] as Map;
        subtaskMap['isDone'] = !subtaskMap['isDone'];
        _updateTaskStatus(taskMap);
        notifyListeners();
      }
    }
  }

  void setTaskCover(String taskId, Color? color, {String size = 'header'}) {
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => {},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      taskMap['coverColor'] = color?.value;
      taskMap['coverSize'] = size;
      notifyListeners();
    }
  }

  void reorderBoardLists(String boardId, int oldIndex, int newIndex) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final boardMap = board as Map;
      final List currentLists = List.from(boardMap['lists'] ?? []);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = currentLists.removeAt(oldIndex);
      currentLists.insert(newIndex, item);
      boardMap['lists'] = currentLists;
      notifyListeners();
    }
  }

  void addPoll(String boardId, String question, List options) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final boardMap = board as Map;
      boardMap['polls'] ??= [];
      (boardMap['polls'] as List).add({
        'id': 'poll_${DateTime.now().millisecondsSinceEpoch}',
        'question': question,
        'creator': currentUserProfile['name'] ?? 'Pengguna',
        'createdAt': 'Hari ini',
        'isClosed': false,
        'options': options.map((opt) => {'text': opt, 'votes': []}).toList(),
      });
      logActivity('Membuat polling baru: "$question"');
      notifyListeners();
    }
  }

  void votePoll(String boardId, String pollId, int optionIndex) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty && (board as Map)['polls'] != null) {
      final userName = currentUserProfile['name'] ?? 'Pengguna';
      for (var poll in (board['polls'] as List)) {
        final pollMap = poll as Map;
        if (pollMap['id'] == pollId && pollMap['isClosed'] != true) {
          final options = pollMap['options'] as List;
          for (var opt in options) {
            ((opt as Map)['votes'] as List).remove(userName);
          }
          if (optionIndex >= 0 && optionIndex < options.length) {
            ((options[optionIndex] as Map)['votes'] as List).add(userName);
          }
          notifyListeners();
          break;
        }
      }
    }
  }

  void togglePollStatus(String boardId, String pollId) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty && (board as Map)['polls'] != null) {
      for (var poll in (board['polls'] as List)) {
        final pollMap = poll as Map;
        if (pollMap['id'] == pollId) {
          pollMap['isClosed'] = !(pollMap['isClosed'] ?? false);
          notifyListeners();
          break;
        }
      }
    }
  }

  void deletePoll(String boardId, String pollId) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty && (board as Map)['polls'] != null) {
      (board['polls'] as List).removeWhere((p) => (p as Map)['id'] == pollId);
      notifyListeners();
    }
  }

  void updateBoardDetails(
    String boardId, {
    String? title,
    String? desc,
    int? color,
    String? privacy,
  }) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final boardMap = board as Map;
      if (title != null && title.trim().isNotEmpty)
        boardMap['title'] = title.trim();
      if (desc != null) boardMap['desc'] = desc.trim();
      if (color != null) boardMap['color'] = color;
      if (privacy != null) boardMap['privacy'] = privacy;
      logActivity('Memperbarui informasi board "${boardMap['title']}"');
      notifyListeners();
    }
  }

  void addBoardMember(String boardId, String name, {int? color}) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final boardMap = board as Map;
      boardMap['members'] ??= [];
      final List members = boardMap['members'];
      final bool alreadyExists = members.any(
        (m) =>
            ((m as Map)['name'] as String).toLowerCase() ==
            name.trim().toLowerCase(),
      );
      if (!alreadyExists && name.trim().isNotEmpty) {
        final colors = [
          0xFF0F766E,
          0xFF3B82F6,
          0xFF10B981,
          0xFFF59E0B,
          0xFF8B5CF6,
          0xFFEF4444,
        ];
        final pickedColor = color ?? colors[members.length % colors.length];
        members.add({
          'name': name.trim(),
          'color': pickedColor,
          'role': 'Anggota',
        });
        logActivity('Menambahkan anggota "$name" ke board');
        notifyListeners();
      }
    }
  }

  void removeBoardMember(String boardId, String memberName) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty && (board as Map)['members'] != null) {
      (board['members'] as List).removeWhere(
        (m) => (m as Map)['name'] == memberName,
      );
      logActivity('Mengeluarkan anggota "$memberName" dari board');
      notifyListeners();
    }
  }

  void addBoardFile(
    String boardId,
    String fileName,
    String size, {
    String extension = 'file',
  }) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty) {
      final boardMap = board as Map;
      boardMap['files'] ??= [];
      (boardMap['files'] as List).add({
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
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => {},
    );
    if (board.isNotEmpty && (board as Map)['files'] != null) {
      (board['files'] as List).removeWhere((f) => (f as Map)['id'] == fileId);
      notifyListeners();
    }
  }

  // Catatan: implementasi async deleteBoard sudah ada di atas

  void addComment(String taskId, String text) {
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => {},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      (taskMap['comments'] as List).add({
        'author': currentUserProfile['name'],
        'text': text,
        'time': 'Baru saja',
      });
      logActivity('Mengomentari tugas: "${taskMap['title']}"');
      notifyListeners();
    }
  }

  void setTaskStartDate(String taskId, String date, String time) {
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => {},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      taskMap['startDate'] = date;
      taskMap['startTime'] = time;
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
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => {},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      taskMap['dueDate'] = date;
      taskMap['dueTime'] = time;
      taskMap['reminder'] = reminder;
      taskMap['addMeToCard'] = addMeToCard;
      if (date != 'Tanggal') taskMap['date'] = date;
      notifyListeners();
    }
  }
}
