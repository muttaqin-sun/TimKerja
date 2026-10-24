import 'package:flutter/material.dart';

class AppDataController extends ChangeNotifier {
  static final AppDataController instance = AppDataController._internal();
  AppDataController._internal();

  // 1. DATA PROFIL & RBAC GLOBAL
  // Ubah value ini menjadi 'Anggota' jika ingin mengetes fitur Join Board
  String currentUserRole = 'Pembuat Board';
  Map<String, dynamic> currentUserProfile = {
    'name': 'Ilham',
    'email': 'ilham@student.ac.id',
    'initials': 'IM',
    'avatarColor': 0xFF0F766E,
  };

  // 2. Data Boards (Ditambahkan 'code')
  List<Map<String, dynamic>> boards = [
    {
      'id': 'b1',
      'title': 'Kuliah - TI',
      'desc': 'Proyek tugas pemrograman & UI/UX',
      'color': 0xFF004D40,
      'privacy': 'Private',
      'code': 'KULIAH-TI-8X2P', // Kode dummy
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
      'code': 'PROJ-A-9Y3Q', // Kode dummy
      'lists': ['Tahap 1', 'Tahap 2', 'Selesai'],
      'lockedLists': <String>['Selesai'],
      'members': [
        {'name': 'Ilham', 'color': 0xFF0F766E},
        {'name': 'Andi', 'color': 0xFFF59E0B},
      ],
    },
  ];

  // (Data Tasks, Notifications, Recent Activities tidak berubah)
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

  // --- METHODS ---

  void addBoard(
    String title,
    String desc,
    dynamic color,
    String privacy, {
    List<String>? initialLists,
  }) {
    String generateCode() {
      // Dummy generator kode sederhana
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
    notifyListeners();
  }

  // TODO: Supabase Integration - Akan diganti dengan request API RPC ke backend
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
        notifyListeners();
        return true;
      }
    }
    return false;
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
      'subtasks': <Map<String, dynamic>>[],
      'comments': <Map<String, dynamic>>[],
      'attachments': <Map<String, dynamic>>[],
      'members': <Map<String, dynamic>>[],
    });
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

  void addComment(String taskId, String text) {
    final task = tasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
    if (task.isNotEmpty) {
      (task['comments'] as List).add({
        'author': currentUserProfile['name'],
        'text': text,
        'time': 'Baru saja',
      });
      notifyListeners();
    }
  }
}
