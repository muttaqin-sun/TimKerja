import 'package:flutter/material.dart';

import '../main.dart';
import '../services/profile_service.dart';
import '../services/board_service.dart';
import '../services/task_service.dart';
import '../services/poll_service.dart';
import '../services/notification_service.dart';
import '../services/local_notification_service.dart';
import '../widgets/mention_suggestion_box.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:io';

class AppDataController extends ChangeNotifier {
  static final AppDataController instance = AppDataController._internal();
  AppDataController._internal();

  RealtimeChannel? _notifChannel;

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
    notifications = [];
    recentActivities = [];
    currentNavIndex.value = 0;
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
      rawLists.sort(
        (a, b) => (a['position'] ?? 0).compareTo(b['position'] ?? 0),
      );
      final List<String> listTitles = rawLists
          .map((l) => l['title'].toString())
          .toList();

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

    final boardIds = boards
        .map((b) => b['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    if (boardIds.isNotEmpty) {
      final allRawTasks = await TaskService.fetchTasksForBoards(boardIds);
      tasks = allRawTasks.map(_mapRawTaskToLocal).toList();
    } else {
      tasks.clear();
    }

    await initNotificationsRealtime();

    for (final b in boards) {
      final bid = b['id']?.toString() ?? '';
      if (bid.isNotEmpty) {
        checkAndNotifyTaskDeadlines(bid);
      }
    }
    await loadRecentActivities();

    notifyListeners();
  }

  Map<String, dynamic> _mapRawTaskToLocal(Map<String, dynamic> raw) {
    final List rawSubtasks = raw['subtasks'] as List? ?? [];
    final List<Map<String, dynamic>> subtasksList = rawSubtasks
        .map(
          (s) => {
            'id': s['id'],
            'title': s['title'] ?? '',
            'isDone': s['is_done'] ?? false,
          },
        )
        .toList();

    final List rawComments = raw['task_comments'] as List? ?? [];
    final List<Map<String, dynamic>> commentsList = rawComments.map((c) {
      final prof = c['profiles'] as Map? ?? {};
      return {
        'id': c['id'],
        'author': prof['name'] ?? 'User',
        'text': c['text'] ?? '',
        'time': 'Baru saja',
      };
    }).toList();

    final List rawAttachments = raw['task_attachments'] as List? ?? [];
    final List<Map<String, dynamic>> attachmentsList = rawAttachments
        .map(
          (a) => {
            'id': a['id'].toString(),
            'name': a['name'] ?? 'Lampiran',
            'url': a['url'] ?? '',
            'type': a['type'] ?? 'link',
          },
        )
        .toList();

    final List rawMembers = raw['task_members'] as List? ?? [];
    final List<Map<String, dynamic>> membersList = rawMembers.map((tm) {
      final prof = tm['profiles'] as Map? ?? {};
      return {
        'userId': (prof['id'] ?? tm['user_id'] ?? '').toString(),
        'name': prof['name']?.toString() ?? 'Anggota',
        'color': prof['avatar_color'] ?? 0xFF00A896,
      };
    }).toList();

    return {
      'id': raw['id'].toString(),
      'boardId': raw['board_id'].toString(),
      'listName': raw['list_name'] ?? 'To Do',
      'title': raw['title'] ?? '',
      'status': raw['status'] ?? 'To Do',
      'priority': raw['priority'] ?? 'Low',
      'date': raw['due_date'] ?? 'No Date',
      'desc': raw['description'] ?? '',
      'isDone': raw['is_done'] == true,
      'reviewStatus': raw['review_status'] ?? 'none',
      'reviewNote': raw['review_note'],
      'dueNotified': raw['due_notified'] == true,
      'coverColor': raw['cover_color'],
      'coverSize': raw['cover_size'] ?? 'header',
      'startDate': raw['start_date'],
      'startTime': raw['start_time'],
      'dueDate': raw['due_date'],
      'dueTime': raw['due_time'],
      'reminder': raw['reminder'] ?? '1 hari sebelumnya',
      'addMeToCard': raw['add_me_to_card'] == true,
      'subtasks': subtasksList,
      'comments': commentsList,
      'attachments': attachmentsList,
      'members': membersList,
    };
  }

  // Load Task & List terbaru dari Supabase untuk 1 Board tertentu
  Future<void> loadTasksForBoard(String boardId) async {
    final fetchedLists = await TaskService.fetchBoardLists(boardId);
    final boardIndex = boards.indexWhere(
      (b) => (b as Map)['id'].toString() == boardId,
    );
    if (boardIndex != -1) {
      final boardMap = boards[boardIndex] as Map;
      boardMap['lists'] = fetchedLists
          .map((l) => l['title'].toString())
          .toList();
      boardMap['lockedLists'] = fetchedLists
          .where((l) => l['is_locked'] == true)
          .map((l) => l['title'].toString())
          .toList();
    }

    final fetched = await TaskService.fetchTasksByBoard(boardId);
    tasks.removeWhere((t) => (t as Map)['boardId'].toString() == boardId);

    for (final raw in fetched) {
      tasks.add(_mapRawTaskToLocal(raw));
    }

    notifyListeners();
  }

  Future<bool> addBoardList(String boardId, String listTitle) async {
    try {
      final bId = boardId.toString();
      final boardIndex = boards.indexWhere(
        (b) => (b as Map)['id'].toString() == bId,
      );
      final List currentLists = boardIndex != -1
          ? List.from((boards[boardIndex] as Map)['lists'] ?? [])
          : [];

      await TaskService.createBoardList(
        boardId: bId,
        title: listTitle,
        position: currentLists.length,
      );

      if (boardIndex != -1 && !currentLists.contains(listTitle)) {
        currentLists.add(listTitle);
        (boards[boardIndex] as Map)['lists'] = currentLists;
        notifyListeners();
      }

      await loadTasksForBoard(bId);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Load Semua Task Pengguna (untuk TasksTab)
  Future<void> loadAllUserTasks(String userId) async {
    final fetched = await TaskService.fetchAllUserTasks(userId);
    tasks = fetched.map((raw) {
      final board = raw['boards'] as Map? ?? {};
      final List rawSubtasks = raw['subtasks'] as List? ?? [];
      final List<Map<String, dynamic>> subtasksList = rawSubtasks
          .map(
            (s) => {
              'id': s['id'],
              'title': s['title'] ?? '',
              'isDone': s['is_done'] ?? false,
            },
          )
          .toList();

      return {
        'id': raw['id'].toString(),
        'boardId': raw['board_id'].toString(),
        'boardName': board['title'] ?? '',
        'listName': raw['list_name'] ?? 'To Do',
        'title': raw['title'] ?? '',
        'status': raw['status'] ?? 'To Do',
        'priority': raw['priority'] ?? 'Low',
        'date': raw['due_date'] ?? 'No Date',
        'desc': raw['description'] ?? '',
        'isDone': raw['is_done'] ?? false,
        'coverColor': raw['cover_color'],
        'coverSize': raw['cover_size'] ?? 'header',
        'reviewStatus': raw['review_status']?.toString() ?? 'none',
        'dueNotified': raw['due_notified'] == true,
        'reviewNote': raw['review_note']?.toString(),
        'startDate': raw['start_date'],
        'startTime': raw['start_time'],
        'dueDate': raw['due_date'],
        'dueTime': raw['due_time'],
        'reminder': raw['reminder'] ?? '1 hari sebelumnya',
        'addMeToCard': false,
        'subtasks': subtasksList,
        'comments': [],
        'attachments': [],
        'members': [],
      };
    }).toList();

    notifyListeners();
  }

  /// Segarkan daftar lampiran dari Supabase untuk task yang sedang dibuka
  Future<void> loadTaskAttachments(String taskId) async {
    final rawAttachments = await TaskService.fetchTaskAttachments(taskId);
    final task = tasks.firstWhere(
      (t) => t['id'].toString() == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isNotEmpty) {
      task['attachments'] = rawAttachments
          .map(
            (a) => {
              'id': a['id'].toString(),
              'name': a['name'] ?? 'Lampiran',
              'url': a['url'] ?? '',
              'type': a['type'] ?? 'link',
            },
          )
          .toList();
      notifyListeners();
    }
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

  List tasks = [];

  List notifications = [];

  // Navigasi antar-tab utama (0: Home, 1: Tasks, 2: Notifications, 3: Profile)
  final ValueNotifier<int> currentNavIndex = ValueNotifier<int>(0);

  void switchMainTab(int index) {
    currentNavIndex.value = index;
  }

  // Riwayat aktivitas real-time dari Supabase (bebas data dummy)
  List recentActivities = [];

  List get todayTasks {
    final now = DateTime.now();
    return tasks.where((t) {
      final taskMap = Map<String, dynamic>.from(t as Map);
      final rawDue = (taskMap['dueDate']?.toString() ?? '').trim();
      final rawLegacy = (taskMap['date']?.toString() ?? '').trim();

      if (rawLegacy == 'Today' ||
          rawLegacy == 'Hari ini' ||
          rawDue == 'Hari ini' ||
          rawDue.toLowerCase() == 'today') {
        return true;
      }

      final parsedDue = parseTaskDueDateTime(taskMap);
      if (parsedDue != null &&
          parsedDue.year == now.year &&
          parsedDue.month == now.month &&
          parsedDue.day == now.day) {
        return true;
      }

      return false;
    }).toList();
  }

  String _formatActivityTime(DateTime dt) {
    final local = dt.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m/${local.year} • $h:$min';
  }

  /// Catat aktivitas ke state lokal sekaligus simpan permanen ke Supabase
  Future<void> logActivity(
    String actionText, {
    String? boardId,
    String targetType = 'board',
    String? targetId,
  }) async {
    final userId = currentUserProfile['id']?.toString() ?? '';
    final userName = currentUserProfile['name']?.toString() ?? 'Pengguna';
    if (userId.isEmpty) return;

    final now = DateTime.now();
    final entry = <String, dynamic>{
      'id': 'local_${now.millisecondsSinceEpoch}',
      'boardId': boardId,
      'userId': userId,
      'userName': userName,
      'title': '$userName $actionText',
      'time': 'Baru saja',
      'targetType': targetType,
      'targetId': targetId,
      'timestamp': now,
    };

    recentActivities.insert(0, entry);
    if (recentActivities.length > 30) {
      recentActivities = recentActivities.sublist(0, 30);
    }
    notifyListeners();

    try {
      await supabase.from('activity_logs').insert({
        if (boardId != null && boardId.isNotEmpty) 'board_id': boardId,
        'user_id': userId,
        'user_name': userName,
        'action_text': actionText,
        'target_type': targetType,
        if (targetId != null && targetId.isNotEmpty) 'target_id': targetId,
      });
    } catch (e) {
      print('ERROR logActivity Supabase: $e');
    }
  }

  /// Muat ulang riwayat aktivitas dari Supabase agar tahan terhadap force close
  Future<void> loadRecentActivities() async {
    final userId = currentUserProfile['id']?.toString() ?? '';
    if (userId.isEmpty) return;

    try {
      final boardIds = boards
          .map((b) => b['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      final query = supabase.from('activity_logs').select();
      final res = boardIds.isNotEmpty
          ? await query
                .or('user_id.eq.$userId,board_id.in.(${boardIds.join(',')})')
                .order('created_at', ascending: false)
                .limit(30)
          : await query
                .eq('user_id', userId)
                .order('created_at', ascending: false)
                .limit(30);

      final rows = List<Map<String, dynamic>>.from(res);
      recentActivities = rows.map((r) {
        final createdAt =
            DateTime.tryParse(r['created_at']?.toString() ?? '') ??
            DateTime.now();
        final actor = r['user_name']?.toString() ?? 'Anggota';
        final action = r['action_text']?.toString() ?? '';
        return <String, dynamic>{
          'id': r['id']?.toString() ?? '',
          'boardId': r['board_id']?.toString(),
          'userId': r['user_id']?.toString(),
          'userName': actor,
          'title': '$actor $action',
          'time': _formatActivityTime(createdAt),
          'targetType': r['target_type']?.toString() ?? 'board',
          'targetId': r['target_id']?.toString(),
          'timestamp': createdAt,
        };
      }).toList();

      notifyListeners();
    } catch (e) {
      print('ERROR loadRecentActivities: $e');
    }
  }

  /// Ambil daftar tugas yang jatuh tempo hari ini atau belum selesai & melewati tenggat hari ini
  List getTodayTasks({required Set<String> visibleBoardIds}) {
    final now = DateTime.now();

    return tasks.where((t) {
      final boardId = t['boardId']?.toString() ?? '';
      if (visibleBoardIds.isNotEmpty && !visibleBoardIds.contains(boardId)) {
        return false;
      }

      final rawDue = (t['dueDate']?.toString() ?? '').trim();
      final rawLegacyDate = (t['date']?.toString() ?? '').trim();

      if (rawDue == 'Hari ini' ||
          rawDue.toLowerCase() == 'today' ||
          rawLegacyDate == 'Today' ||
          rawLegacyDate == 'Hari ini') {
        return true;
      }

      final parsedDue = parseTaskDueDateTime(t);
      if (parsedDue != null) {
        final isSameDay =
            parsedDue.year == now.year &&
            parsedDue.month == now.month &&
            parsedDue.day == now.day;
        if (isSameDay) return true;
      }

      return false;
    }).toList();
  }

  // ===========================================================================
  // MANAJEMEN NOTIFIKASI REALTIME & SYSTEM TRAY
  // ===========================================================================

  IconData _mapNotifIcon(String type) {
    switch (type) {
      case 'Mentions':
        return Icons.alternate_email_rounded;
      case 'Assignments':
        return Icons.assignment_turned_in_outlined;
      case 'Due Dates':
        return Icons.event_busy_rounded;
      case 'Polls':
        return Icons.bar_chart_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Map<String, dynamic> _normalizeNotifMap(Map<String, dynamic> raw) {
    final String rawType = (raw['type']?.toString() ?? 'All').trim();
    String normalizedType = rawType;
    if (rawType.toLowerCase().contains('poll')) {
      normalizedType = 'Polls';
    } else if (rawType.toLowerCase().contains('mention')) {
      normalizedType = 'Mentions';
    } else if (rawType.toLowerCase().contains('assign')) {
      normalizedType = 'Assignments';
    } else if (rawType.toLowerCase().contains('due')) {
      normalizedType = 'Due Dates';
    }

    final DateTime ts = raw['created_at'] != null
        ? DateTime.tryParse(raw['created_at'].toString()) ?? DateTime.now()
        : DateTime.now();

    return {
      'id': raw['id'].toString(),
      'title': raw['title']?.toString() ?? '',
      'subtitle': raw['subtitle']?.toString() ?? '',
      'type': normalizedType,
      'priority': raw['priority']?.toString() ?? 'Medium',
      'isRead': raw['is_read'] == true,
      'boardId': raw['board_id']?.toString(),
      'referenceId': raw['reference_id']?.toString(),
      'timestamp': ts,
      'time': _formatRelativeTime(ts),
      'icon': _mapNotifIcon(normalizedType),
    };
  }

  /// Muat notifikasi user & aktifkan listener Realtime + System Tray Notification
  Future<void> refreshNotifications() async {
    final userId = currentUserProfile['id']?.toString() ?? '';
    if (userId.isEmpty) return;

    final rawList = await NotificationService.fetchUserNotifications(userId);
    notifications = rawList.map(_normalizeNotifMap).toList();
    notifyListeners();
  }

  Future<void> initNotificationsRealtime() async {
    final userId = currentUserProfile['id']?.toString() ?? '';
    if (userId.isEmpty) return;

    await LocalNotificationService.requestPermission();
    await refreshNotifications();

    if (_notifChannel != null) {
      await supabase.removeChannel(_notifChannel!);
      _notifChannel = null;
    }

    _notifChannel = supabase
        .channel('realtime_notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isEmpty) return;

            final newId = newRecord['id']?.toString() ?? '';
            if (notifications.any((n) => n['id'] == newId)) return;

            final normalized = _normalizeNotifMap(newRecord);
            notifications.insert(0, normalized);
            notifyListeners();

            // Tampilkan notifikasi sistem Android
            LocalNotificationService.showNotification(
              id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
              title: normalized['title'],
              body: normalized['subtitle'],
            );
          },
        )
        .subscribe();
  }

  Future<void> markNotificationAsRead(String notifId) async {
    final idx = notifications.indexWhere((n) => n['id'] == notifId);
    if (idx != -1 && notifications[idx]['isRead'] == false) {
      notifications[idx]['isRead'] = true;
      notifyListeners();
      await NotificationService.markAsRead(notifId);
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final userId = currentUserProfile['id']?.toString() ?? '';
    bool isChanged = false;
    for (var notif in notifications) {
      if (notif['isRead'] == false) {
        notif['isRead'] = true;
        isChanged = true;
      }
    }
    if (isChanged) {
      notifyListeners();
      if (userId.isNotEmpty) {
        await NotificationService.markAllAsRead(userId);
      }
    }
  }

  Future<void> deleteNotification(String notifId) async {
    notifications.removeWhere((n) => n['id'] == notifId);
    notifyListeners();
    await NotificationService.deleteNotification(notifId);
  }

  /// Deteksi @mention pada pesan/komentar dan kirim notifikasi kategori 'Mentions'
  Future<void> processMentionsAndNotify({
    required String boardId,
    required String contentText,
    required String contextLabel, // Contoh: 'Chat Board' atau 'Task: Desain UI'
    String? referenceId,
  }) async {
    final senderId = currentUserProfile['id']?.toString() ?? '';
    final senderName = currentUserProfile['name']?.toString() ?? 'Seseorang';
    if (senderId.isEmpty) return;

    final board = boards.firstWhere(
      (b) => b['id'].toString() == boardId,
      orElse: () => <String, dynamic>{},
    );
    if (board.isEmpty) return;

    final List members = (board['members'] as List?) ?? [];
    final mentionedIds = MentionHelper.extractMentionedUserIds(
      text: contentText,
      boardMembers: members,
      excludeUserId: senderId,
    );

    if (mentionedIds.isEmpty) return;

    final boardTitle = board['title']?.toString() ?? 'Board';
    await NotificationService.sendBulkNotifications(
      targetUserIds: mentionedIds,
      title: '$senderName menyebut Anda ($boardTitle)',
      subtitle: 'Di $contextLabel: "$contentText"',
      type: 'Mentions',
      priority: 'High',
      boardId: boardId,
      referenceId: referenceId,
    );
  }

  /// Helper internal untuk mengambil daftar userId penerima notifikasi task
  List<String> _getTaskTargetUserIds(
    Map<String, dynamic> task,
    Map<String, dynamic> board, {
    required bool onlyManagers,
    String? excludeUserId,
  }) {
    final List boardMembers = (board['members'] as List?) ?? [];

    if (onlyManagers) {
      return boardMembers
          .where((m) {
            if (m is! Map) return false;
            final role = (m['role']?.toString() ?? '').toLowerCase();
            return role == 'manager' || role == 'owner' || role == 'admin';
          })
          .map((m) => m['userId']?.toString() ?? '')
          .where((uid) => uid.isNotEmpty && uid != excludeUserId)
          .toList();
    }

    final List taskMembers = (task['members'] as List?) ?? [];
    final sourceList = taskMembers.isNotEmpty ? taskMembers : boardMembers;
    return sourceList
        .map((m) => (m is Map ? m['userId']?.toString() : '') ?? '')
        .where((uid) => uid.isNotEmpty && uid != excludeUserId)
        .toList();
  }

  /// Kirim notifikasi ketika anggota ditugaskan ke sebuah task
  Future<void> notifyTaskAssigned({
    required String boardId,
    required String taskId,
    required String taskTitle,
    required List<String> assigneeUserIds,
  }) async {
    final senderId = currentUserProfile['id']?.toString() ?? '';
    final senderName = currentUserProfile['name']?.toString() ?? 'Manager';
    final board = boards.firstWhere(
      (b) => b['id'].toString() == boardId,
      orElse: () => <String, dynamic>{},
    );
    final boardTitle = board['title']?.toString() ?? 'Board';

    final targets = assigneeUserIds
        .where((uid) => uid.isNotEmpty && uid != senderId)
        .toList();
    if (targets.isEmpty) return;

    await NotificationService.sendBulkNotifications(
      targetUserIds: targets,
      title: 'Tugas Baru di $boardTitle',
      subtitle: '$senderName menugaskan Anda pada "$taskTitle"',
      type: 'Assignments',
      priority: 'Medium',
      boardId: boardId,
      referenceId: taskId,
    );
  }

  /// Simpan anggota yang ditugaskan ke task & kirim notifikasi 'Assignments' ke anggota baru
  Future<void> updateTaskAssignees({
    required String taskId,
    required List<Map<String, dynamic>> selectedMembers,
  }) async {
    final idx = tasks.indexWhere((t) => t['id'].toString() == taskId);
    if (idx == -1) return;

    final task = tasks[idx];
    final String boardId = task['boardId']?.toString() ?? '';
    final String taskTitle = task['title']?.toString() ?? 'Tugas';

    // Ambil ID anggota lama agar notifikasi hanya terkirim ke anggota yang baru ditambahkan
    final List oldMembers = (task['members'] as List?) ?? [];
    final Set<String> oldIds = oldMembers
        .map((m) => (m is Map ? m['userId']?.toString() : '') ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final List<String> newIds = selectedMembers
        .map((m) => m['userId']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    final List<String> newlyAddedIds = newIds
        .where((id) => !oldIds.contains(id))
        .toList();

    // Perbarui state UI lokal secara instan
    task['members'] = List<Map<String, dynamic>>.from(selectedMembers);
    notifyListeners();

    // Simpan ke tabel task_members di Supabase
    await TaskService.syncTaskMembers(taskId: taskId, userIds: newIds);

    // Kirim notifikasi kategori 'Assignments' ke anggota yang baru ditugaskan
    if (newlyAddedIds.isNotEmpty && boardId.isNotEmpty) {
      await notifyTaskAssigned(
        boardId: boardId,
        taskId: taskId,
        taskTitle: taskTitle,
        assigneeUserIds: newlyAddedIds,
      );
    }
  }

  /// Member mengajukan tugas selesai untuk divalidasi oleh Manager
  Future<void> submitTaskForReview(String taskId) async {
    final idx = tasks.indexWhere((t) => t['id'].toString() == taskId);
    if (idx == -1) return;

    final task = tasks[idx];
    final String boardId = task['boardId']?.toString() ?? '';
    final String taskTitle = task['title']?.toString() ?? 'Tugas';
    final String senderId = currentUserProfile['id']?.toString() ?? '';
    final String senderName =
        currentUserProfile['name']?.toString() ?? 'Anggota';

    final board = boards.firstWhere(
      (b) => b['id'].toString() == boardId,
      orElse: () => <String, dynamic>{},
    );

    // Cek apakah user saat ini adalah Manager
    final List boardMembers = (board['members'] as List?) ?? [];
    final me = boardMembers.firstWhere(
      (m) => m is Map && m['userId']?.toString() == senderId,
      orElse: () => <String, dynamic>{},
    );
    final myRole = (me['role']?.toString() ?? '').toLowerCase();
    final bool isManager =
        myRole == 'manager' || myRole == 'owner' || myRole == 'admin';

    final String nextReviewStatus = isManager ? 'approved' : 'pending_review';

    task['status'] = 'Done';
    task['isDone'] = true;
    task['reviewStatus'] = nextReviewStatus;
    notifyListeners();

    await TaskService.updateTaskReview(
      taskId: taskId,
      status: 'Done',
      isDone: true,
      reviewStatus: nextReviewStatus,
      reviewNote: task['reviewNote']?.toString(),
    );

    if (!isManager && board.isNotEmpty) {
      final managerIds = _getTaskTargetUserIds(
        task,
        board,
        onlyManagers: true,
        excludeUserId: senderId,
      );
      final boardTitle = board['title']?.toString() ?? 'Board';

      await NotificationService.sendBulkNotifications(
        targetUserIds: managerIds,
        title: 'Perlu Validasi Tugas ($boardTitle)',
        subtitle:
            '$senderName menyelesaikan "$taskTitle" dan menunggu persetujuan Anda.',
        type: 'Assignments',
        priority: 'High',
        boardId: boardId,
        referenceId: taskId,
      );
    }
  }

  /// Keputusan Manager: Setujui (Valid) atau Minta Revisi beserta catatan
  Future<void> reviewTaskDecision({
    required String taskId,
    required bool isApproved,
    String? reviewNote,
  }) async {
    final idx = tasks.indexWhere((t) => t['id'].toString() == taskId);
    if (idx == -1) return;

    final task = tasks[idx];
    final String boardId = task['boardId']?.toString() ?? '';
    final String taskTitle = task['title']?.toString() ?? 'Tugas';
    final String managerId = currentUserProfile['id']?.toString() ?? '';
    final String managerName =
        currentUserProfile['name']?.toString() ?? 'Manager';

    final String newStatus = isApproved ? 'Done' : 'In Progress';
    final bool newIsDone = isApproved;
    final String newReviewStatus = isApproved ? 'approved' : 'revision';
    final String? cleanedNote =
        (reviewNote != null && reviewNote.trim().isNotEmpty)
        ? reviewNote.trim()
        : null;

    task['status'] = newStatus;
    task['isDone'] = newIsDone;
    task['reviewStatus'] = newReviewStatus;
    task['reviewNote'] = cleanedNote;
    notifyListeners();

    await TaskService.updateTaskReview(
      taskId: taskId,
      status: newStatus,
      isDone: newIsDone,
      reviewStatus: newReviewStatus,
      reviewNote: cleanedNote,
    );

    logActivity(
      isApproved
          ? 'Menyetujui (Valid) tugas "$taskTitle"'
          : 'Meminta revisi pada tugas "$taskTitle"',
    );

    final board = boards.firstWhere(
      (b) => b['id'].toString() == boardId,
      orElse: () => <String, dynamic>{},
    );
    if (board.isNotEmpty) {
      final memberIds = _getTaskTargetUserIds(
        task,
        board,
        onlyManagers: false,
        excludeUserId: managerId,
      );
      final boardTitle = board['title']?.toString() ?? 'Board';

      await NotificationService.sendBulkNotifications(
        targetUserIds: memberIds,
        title: isApproved
            ? 'Tugas Disetujui (Valid) • $boardTitle'
            : 'Permintaan Revisi Tugas • $boardTitle',
        subtitle: isApproved
            ? '$managerName memvalidasi tugas "$taskTitle" sebagai selesai.'
            : '$managerName meminta revisi pada "$taskTitle"${cleanedNote != null ? ': "$cleanedNote"' : '.'}',
        type: 'Assignments',
        priority: isApproved ? 'Medium' : 'High',
        boardId: boardId,
        referenceId: taskId,
      );
    }
  }

  /// Mengonversi pasangan task['dueDate'] dan task['dueTime'] menjadi DateTime lokal
  DateTime? parseTaskDueDateTime(Map<String, dynamic> task) {
    final String rawDate = (task['dueDate']?.toString() ?? '').trim();
    if (rawDate.isEmpty || rawDate == 'Tanggal' || rawDate == 'null') {
      return null;
    }

    final String rawTime = (task['dueTime']?.toString() ?? '').trim();
    int hour = 23;
    int minute = 59;

    if (rawTime.isNotEmpty && rawTime != 'Waktu' && rawTime != 'null') {
      if (rawTime == 'Pagi') {
        hour = 9;
        minute = 0;
      } else if (rawTime == 'Siang') {
        hour = 12;
        minute = 0;
      } else if (rawTime == 'Sore') {
        hour = 15;
        minute = 0;
      } else if (rawTime == 'Malam') {
        hour = 20;
        minute = 0;
      } else {
        final normalizedTime = rawTime.replaceAll('.', ':');
        final parts = normalizedTime.split(':');
        if (parts.length >= 2) {
          hour = int.tryParse(parts[0]) ?? 23;
          minute = int.tryParse(parts[1]) ?? 59;
        }
      }
    }

    final now = DateTime.now();
    if (rawDate == 'Hari ini') {
      return DateTime(now.year, now.month, now.day, hour, minute);
    } else if (rawDate == 'Besok') {
      final tmr = now.add(const Duration(days: 1));
      return DateTime(tmr.year, tmr.month, tmr.day, hour, minute);
    } else if (rawDate == 'Minggu Depan') {
      final nextWeek = now.add(const Duration(days: 7));
      return DateTime(
        nextWeek.year,
        nextWeek.month,
        nextWeek.day,
        hour,
        minute,
      );
    }

    // Format dd/MM/yyyy (hasil DatePicker di TaskDetailScreen)
    if (rawDate.contains('/')) {
      final dParts = rawDate.split('/');
      if (dParts.length == 3) {
        final day = int.tryParse(dParts[0]);
        final month = int.tryParse(dParts[1]);
        final year = int.tryParse(dParts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day, hour, minute);
        }
      }
    }

    // Fallback jika tersimpan sebagai ISO-8601
    final parsedIso = DateTime.tryParse(rawDate);
    if (parsedIso != null) {
      final local = parsedIso.toLocal();
      return DateTime(local.year, local.month, local.day, hour, minute);
    }

    return null;
  }

  /// Mengecek apakah tugas sudah melewati batas waktu dan belum selesai
  bool isTaskOverdue(Map<String, dynamic> task) {
    if (task['isDone'] == true) return false;
    final dueDt = parseTaskDueDateTime(task);
    if (dueDt == null) return false;
    return DateTime.now().isAfter(dueDt);
  }

  /// Mengecek apakah user yang sedang login boleh mengubah isi/status task
  bool canUserEditTask(String taskId) {
    final task = tasks.firstWhere(
      (t) => t['id'].toString() == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isEmpty) return false;

    final String boardId = task['boardId']?.toString() ?? '';
    final String myId = currentUserProfile['id']?.toString() ?? '';
    final board = boards.firstWhere(
      (b) => b['id'].toString() == boardId,
      orElse: () => <String, dynamic>{},
    );

    final List boardMembers = (board['members'] as List?) ?? [];
    final me = boardMembers.firstWhere(
      (m) => m is Map && m['userId']?.toString() == myId,
      orElse: () => <String, dynamic>{},
    );
    final role = (me['role']?.toString() ?? '').toLowerCase();
    final bool isManager =
        role == 'manager' || role == 'owner' || role == 'admin';

    // Manager selalu memiliki akses penuh (termasuk memperpanjang deadline)
    if (isManager) return true;

    // Member biasa terkunci jika tugas sudah melewati tenggat waktu
    return !isTaskOverdue(task);
  }

  /// Periksa tenggat seluruh tugas pada board dan kirim notifikasi kategori 'Due Dates'
  Future<void> checkAndNotifyTaskDeadlines(String boardId) async {
    final board = boards.firstWhere(
      (b) => b['id'].toString() == boardId,
      orElse: () => <String, dynamic>{},
    );
    if (board.isEmpty) return;

    final String boardTitle = board['title']?.toString() ?? 'Board';
    final now = DateTime.now();

    final boardTasks = tasks
        .where((t) => t['boardId']?.toString() == boardId)
        .toList();

    for (final task in boardTasks) {
      if (task['isDone'] == true || task['dueNotified'] == true) continue;

      final dueDt = parseTaskDueDateTime(task);
      if (dueDt == null) continue;

      final bool overdue = now.isAfter(dueDt);
      final bool approaching = !overdue && dueDt.difference(now).inHours < 24;

      if (!overdue && !approaching) continue;

      final String taskId = task['id'].toString();
      final String taskTitle = task['title']?.toString() ?? 'Tugas';

      // Tandai agar notifikasi tidak terkirim berulang kali
      task['dueNotified'] = true;
      supabase
          .from('tasks')
          .update({'due_notified': true})
          .eq('id', taskId)
          .then((_) {});

      // Gabungkan anggota task + Manager board sebagai penerima peringatan
      final targetIds = <String>{
        ..._getTaskTargetUserIds(task, board, onlyManagers: false),
        ..._getTaskTargetUserIds(task, board, onlyManagers: true),
      }.toList();

      await NotificationService.sendBulkNotifications(
        targetUserIds: targetIds,
        title: overdue
            ? 'Tenggat Terlewat ($boardTitle)'
            : 'Mendekati Tenggat ($boardTitle)',
        subtitle: overdue
            ? 'Tugas "$taskTitle" telah melewati batas waktu dan dikunci untuk anggota.'
            : 'Tugas "$taskTitle" akan berakhir dalam kurang dari 24 jam.',
        type: 'Due Dates',
        priority: 'High',
        boardId: boardId,
        referenceId: taskId,
      );
    }
  }

  /// Alias / backward compatibility untuk pengecekan tenggat seluruh task di semua board
  Future<void> checkAndNotifyTaskDueDates() async {
    for (final b in boards) {
      final bid = b['id']?.toString() ?? '';
      if (bid.isNotEmpty) {
        await checkAndNotifyTaskDeadlines(bid);
      }
    }
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

    final colorVal = color is Color
        ? color.value
        : (color as int? ?? 0xFF004D40);

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
        orElse: () => <String, dynamic>{},
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

  Future<void> renameBoardList(
    String boardId,
    String oldName,
    String newName,
  ) async {
    final bId = boardId.toString();
    final board = boards.firstWhere(
      (b) => (b as Map)['id'].toString() == bId,
      orElse: () => <String, dynamic>{},
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
          if (taskMap['boardId'].toString() == bId &&
              taskMap['listName'] == oldName) {
            taskMap['listName'] = newName;
          }
        }
        notifyListeners();

        await TaskService.renameBoardList(
          boardId: bId,
          oldTitle: oldName,
          newTitle: newName,
        );
      }
    }
  }

  Future<void> deleteBoardList(String boardId, String listName) async {
    final bId = boardId.toString();
    try {
      await TaskService.deleteBoardList(boardId: bId, title: listName);

      final boardIndex = boards.indexWhere(
        (b) => (b as Map)['id'].toString() == bId,
      );
      if (boardIndex != -1) {
        final boardMap = boards[boardIndex] as Map;
        final List currentLists = List.from(boardMap['lists'] ?? []);
        currentLists.remove(listName);
        boardMap['lists'] = currentLists;

        boardMap['lockedLists'] ??= [];
        List lockedLists = List.from(boardMap['lockedLists']);
        lockedLists.remove(listName);
        boardMap['lockedLists'] = lockedLists;
      }

      tasks.removeWhere(
        (t) =>
            (t as Map)['boardId'].toString() == bId &&
            t['listName'] == listName,
      );

      logActivity('Menghapus kolom list "$listName"');
      notifyListeners();
    } catch (e) {
      await loadTasksForBoard(bId);
      rethrow;
    }
  }

  Future<void> toggleListLock(String boardId, String listName) async {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => <String, dynamic>{},
    );
    if (board.isNotEmpty) {
      final boardMap = board as Map;
      boardMap['lockedLists'] ??= [];
      List lockedLists = List.from(boardMap['lockedLists']);
      final bool willLock = !lockedLists.contains(listName);
      if (willLock) {
        lockedLists.add(listName);
      } else {
        lockedLists.remove(listName);
      }
      boardMap['lockedLists'] = lockedLists;
      notifyListeners();

      await TaskService.toggleBoardListLock(
        boardId: boardId,
        title: listName,
        isLocked: willLock,
      );
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

  Future<void> moveTaskToList(
    String taskId,
    String targetListName, {
    int? targetIndex,
  }) async {
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

      await TaskService.moveTask(
        taskId: taskId,
        targetListName: targetListName,
        position: targetIndex,
      );
    }
  }

  Future<void> addTask(String boardId, String title, String listName) async {
    final userId = currentUserProfile['id'];
    late final Map<String, dynamic> newTask;
    try {
      final rawRes = await TaskService.createTask(
        boardId: boardId,
        title: title,
        listName: listName,
        userId: userId.toString(),
        position: tasks
            .where((t) => t['boardId'] == boardId && t['listName'] == listName)
            .length,
      );

      final taskId = rawRes != null ? rawRes['id'].toString() : null;
      if (taskId == null) {
        throw Exception('Gagal mendapatkan ID task dari database.');
      }

      newTask = {
        'id': taskId,
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
      };
      tasks.add(newTask);
      logActivity('Menambahkan tugas: "$title"');
      notifyListeners();
    } catch (e) {
      print('CRITICAL: addTask failed: $e');
      rethrow;
    }
    // Ambil daftar userId anggota yang ditugaskan pada task baru (jika ada)
    final List<String> assignedIds = ((newTask['members'] as List?) ?? [])
        .map((m) => (m is Map ? m['userId']?.toString() : '') ?? '')
        .where((uid) => uid.isNotEmpty)
        .toList();

    if (assignedIds.isNotEmpty) {
      await notifyTaskAssigned(
        boardId: boardId,
        taskId: newTask['id'].toString(),
        taskTitle: newTask['title']?.toString() ?? 'Tugas Baru',
        assigneeUserIds: assignedIds,
      );
    }
  }

  Future<void> updateTaskDesc(String taskId, String newDesc) async {
    if (!canUserEditTask(taskId)) return;
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isNotEmpty) {
      (task as Map)['desc'] = newDesc;
      notifyListeners();
      await TaskService.updateTaskDetails(taskId, {'description': newDesc});
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    if (!canUserEditTask(taskId)) return;
    final idx = tasks.indexWhere((t) => t['id'].toString() == taskId);
    if (idx == -1) return;

    final task = tasks[idx];
    final bool wasDone = task['isDone'] == true;

    if (!wasDone) {
      // Saat tugas ditandai selesai -> jalankan alur validasi & notif Manager
      await submitTaskForReview(taskId);
    } else {
      // Saat status selesai dibatalkan -> kembalikan ke To Do
      task['isDone'] = false;
      task['status'] = 'To Do';
      task['reviewStatus'] = 'none';
      notifyListeners();

      await TaskService.updateTaskReview(
        taskId: taskId,
        status: 'To Do',
        isDone: false,
        reviewStatus: 'none',
        reviewNote: task['reviewNote']?.toString(),
      );
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

  Future<void> addSubtask(String taskId, String title) async {
    if (!canUserEditTask(taskId)) return;
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      final rawSubtask = await TaskService.addSubtask(
        taskId: taskId,
        title: title,
      );
      final subtaskId = rawSubtask != null
          ? rawSubtask['id']
          : 'sub_${DateTime.now().millisecondsSinceEpoch}';

      (taskMap['subtasks'] as List).add({
        'id': subtaskId,
        'title': title,
        'isDone': false,
      });
      _updateTaskStatus(taskMap);
      notifyListeners();
    }
  }

  Future<void> toggleSubtask(String taskId, int index) async {
    if (!canUserEditTask(taskId)) return;
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      final subtasks = taskMap['subtasks'] as List;
      if (index >= 0 && index < subtasks.length) {
        final subtaskMap = subtasks[index] as Map;
        subtaskMap['isDone'] = !subtaskMap['isDone'];
        _updateTaskStatus(taskMap);
        notifyListeners();

        if (subtaskMap['id'] != null) {
          await TaskService.toggleSubtask(
            subtaskMap['id'].toString(),
            subtaskMap['isDone'],
          );
        }
      }
    }
  }

  Future<void> deleteSubtask(String taskId, int index) async {
    if (!canUserEditTask(taskId)) return;
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      final subtasks = taskMap['subtasks'] as List;
      if (index >= 0 && index < subtasks.length) {
        final subtaskMap = subtasks[index] as Map;
        final subtaskId = subtaskMap['id']?.toString();
        subtasks.removeAt(index);
        _updateTaskStatus(taskMap);
        notifyListeners();

        if (subtaskId != null) {
          await TaskService.deleteSubtask(subtaskId);
        }
      }
    }
  }

  Future<void> setTaskCover(
    String taskId,
    Color? color, {
    String size = 'header',
  }) async {
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      taskMap['coverColor'] = color?.value;
      taskMap['coverSize'] = size;
      notifyListeners();

      await TaskService.updateTaskDetails(taskId, {
        'cover_color': color?.value,
        'cover_size': size,
      });
    }
  }

  void reorderBoardLists(String boardId, int oldIndex, int newIndex) {
    final board = boards.firstWhere(
      (b) => (b as Map)['id'] == boardId,
      orElse: () => <String, dynamic>{},
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

  /// Muat semua polling untuk board tertentu dari Supabase
  /// Muat semua polling untuk board tertentu dari Supabase
  /// Muat semua polling untuk board tertentu dari Supabase
  Future<void> loadPollsForBoard(String boardId) async {
    final fetched = await PollService.fetchPollsByBoard(boardId);
    final board = boards.firstWhere(
      (b) => b['id'].toString() == boardId,
      orElse: () => <String, dynamic>{},
    );

    if (board.isNotEmpty) {
      final List boardMembers = (board['members'] as List?) ?? [];
      final String boardTitle = board['title']?.toString() ?? 'Board';

      board['polls'] = fetched.map((raw) {
        final String creatorId = raw['created_by']?.toString() ?? '';
        final memberMatch = boardMembers.firstWhere(
          (m) => m['userId']?.toString() == creatorId,
          orElse: () => <String, dynamic>{},
        );
        final String creatorName = memberMatch['name']?.toString() ?? 'Anggota';

        final List rawOptions = List.from(raw['poll_options'] as List? ?? []);
        rawOptions.sort(
          (a, b) => (a['position'] ?? 0).compareTo(b['position'] ?? 0),
        );

        final List rawVotes = raw['poll_votes'] as List? ?? [];
        final DateTime? dueDate = raw['due_date'] != null
            ? DateTime.tryParse(raw['due_date'].toString())
            : null;
        final bool isExpired =
            dueDate != null && DateTime.now().isAfter(dueDate);

        // Kirim notifikasi penutupan polling jika sudah melewati tenggat waktu
        if (isExpired &&
            raw['notify_on_end'] == true &&
            raw['end_notified'] != true) {
          final String pollId = raw['id'].toString();
          final String questionText = raw['question']?.toString() ?? 'Polling';

          // Tandai sudah dinotifikasi di database agar tidak terkirim berulang kali
          supabase
              .from('polls')
              .update({'end_notified': true})
              .eq('id', pollId)
              .then((_) {});

          final List<String> allMemberIds = boardMembers
              .map((m) => m['userId']?.toString() ?? '')
              .where((uid) => uid.isNotEmpty)
              .toList();

          NotificationService.sendBulkNotifications(
            targetUserIds: allMemberIds,
            title: 'Polling Selesai di $boardTitle',
            subtitle: 'Batas waktu polling "$questionText" telah berakhir.',
            type: 'Polls',
            priority: 'Low',
            boardId: boardId,
            referenceId: pollId,
          );
        }

        final List<Map<String, dynamic>> normalizedOptions = rawOptions
            .map<Map<String, dynamic>>((opt) {
              final String optId = opt['id'].toString();
              final List<String> voterIds = rawVotes
                  .where((v) => v['option_id'].toString() == optId)
                  .map((v) => v['user_id'].toString())
                  .toList();

              return {
                'id': optId,
                'title': opt['option_text']?.toString() ?? 'Opsi',
                'votes': voterIds,
              };
            })
            .toList();

        return {
          'id': raw['id'].toString(),
          'boardId': raw['board_id'].toString(),
          'question': raw['question']?.toString() ?? '',
          'creator': creatorName,
          'createdBy': creatorId,
          'createdAt': raw['created_at']?.toString(),
          'dueDate': dueDate,
          'showResultBeforeVote': raw['show_result_before_vote'] ?? true,
          'notifyOnEnd': raw['notify_on_end'] ?? false,
          'isClosed': isExpired,
          'options': normalizedOptions,
        };
      }).toList();

      notifyListeners();
    }
  }

  /// Buat polling baru ke Supabase
  Future<bool> addPoll(
    String boardId,
    String question,
    List<String> options, {
    DateTime? dueDate,
    bool showResultBeforeVote = true,
    bool notifyOnEnd = false,
  }) async {
    final userId = currentUserProfile['id']?.toString() ?? '';
    if (userId.isEmpty) return false;

    final created = await PollService.createPoll(
      boardId: boardId,
      question: question,
      options: options,
      userId: userId,
      dueDate: dueDate,
      showResultBeforeVote: showResultBeforeVote,
      notifyOnEnd: notifyOnEnd,
    );

    if (created != null) {
      logActivity('Membuat polling baru: "$question"');

      // Kirim notifikasi ke seluruh anggota board selain pembuat polling
      final board = boards.firstWhere(
        (b) => b['id'].toString() == boardId,
        orElse: () => <String, dynamic>{},
      );
      final String boardTitle = board['title']?.toString() ?? 'Board';
      final String creatorName =
          currentUserProfile['name']?.toString() ?? 'Anggota';
      final List<String> targetIds = ((board['members'] as List?) ?? [])
          .map((m) => m['userId']?.toString() ?? '')
          .where((uid) => uid.isNotEmpty && uid != userId)
          .toList();

      await NotificationService.sendBulkNotifications(
        targetUserIds: targetIds,
        title: 'Polling Baru di $boardTitle',
        subtitle: '$creatorName membuat polling: "$question"',
        type: 'Polls',
        priority: 'Medium',
        boardId: boardId,
        referenceId: created['id'].toString(),
      );

      await loadPollsForBoard(boardId);
      return true;
    }
    return false;
  }

  /// Kirim suara pada opsi polling tertentu
  Future<void> votePoll(String boardId, String pollId, String optionId) async {
    final userId = currentUserProfile['id']?.toString() ?? '';
    if (userId.isEmpty) return;

    final board = boards.firstWhere(
      (b) => b['id'].toString() == boardId,
      orElse: () => <String, dynamic>{},
    );

    // Optimistic UI update agar responsif seketika
    if (board.isNotEmpty && board['polls'] is List) {
      for (var poll in (board['polls'] as List)) {
        if (poll is Map && poll['id'].toString() == pollId) {
          for (var opt in (poll['options'] as List)) {
            final votes = (opt['votes'] as List);
            votes.remove(userId);
            if (opt['id'].toString() == optionId) {
              votes.add(userId);
            }
          }
          notifyListeners();
          break;
        }
      }
    }

    await PollService.castVote(
      pollId: pollId,
      optionId: optionId,
      userId: userId,
    );
    await loadPollsForBoard(boardId);
  }

  /// Hapus polling dari Supabase
  Future<void> deletePoll(String boardId, String pollId) async {
    final success = await PollService.deletePoll(pollId);
    if (success) {
      final board = boards.firstWhere(
        (b) => b['id'].toString() == boardId,
        orElse: () => <String, dynamic>{},
      );
      if (board.isNotEmpty && board['polls'] is List) {
        (board['polls'] as List).removeWhere(
          (p) => p['id'].toString() == pollId,
        );
        logActivity('Menghapus polling');
        notifyListeners();
      }
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
      orElse: () => <String, dynamic>{},
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
      orElse: () => <String, dynamic>{},
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
      orElse: () => <String, dynamic>{},
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
      orElse: () => <String, dynamic>{},
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
      orElse: () => <String, dynamic>{},
    );
    if (board.isNotEmpty && (board as Map)['files'] != null) {
      (board['files'] as List).removeWhere((f) => (f as Map)['id'] == fileId);
      notifyListeners();
    }
  }

  // Catatan: implementasi async deleteBoard sudah ada di atas

  Future<void> addComment(String taskId, String text) async {
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      final userId = currentUserProfile['id']?.toString() ?? '';
      (taskMap['comments'] as List).add({
        'author': currentUserProfile['name'],
        'text': text,
        'time': 'Baru saja',
      });
      logActivity('Mengomentari tugas: "${taskMap['title']}"');
      notifyListeners();

      if (userId.isNotEmpty) {
        await TaskService.addComment(
          taskId: taskId,
          userId: userId,
          text: text,
        );
      }
    }
  }

  Future<void> setTaskStartDate(String taskId, String date, String time) async {
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      taskMap['startDate'] = date;
      taskMap['startTime'] = time;
      notifyListeners();

      await TaskService.updateTaskDetails(taskId, {
        'start_date': date == 'Tanggal' ? null : date,
        'start_time': time == 'Waktu' ? null : time,
      });
    }
  }

  Future<void> addTaskLinkAttachment(
    String taskId, {
    required String name,
    required String url,
  }) async {
    if (!canUserEditTask(taskId)) return;
    final task = tasks.firstWhere(
      (t) => t['id'].toString() == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isEmpty) return;

    final res = await TaskService.addTaskAttachment(
      taskId: taskId,
      name: name,
      url: url,
      type: 'link',
    );

    if (res != null) {
      (task['attachments'] as List).add({
        'id': res['id'].toString(),
        'name': res['name'],
        'url': res['url'],
        'type': 'link',
      });
      logActivity('Melampirkan tautan "$name" pada "${task['title']}"');
      notifyListeners();
    }
  }

  Future<void> uploadTaskFileAttachment(
    String taskId, {
    required File file,
    required String fileName,
    required String type,
  }) async {
    if (!canUserEditTask(taskId)) return;
    final task = tasks.firstWhere(
      (t) => t['id'].toString() == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isEmpty) return;

    final res = await TaskService.uploadAndAttachFile(
      taskId: taskId,
      file: file,
      fileName: fileName,
      type: type,
    );

    if (res != null) {
      (task['attachments'] as List).add({
        'id': res['id'].toString(),
        'name': res['name'],
        'url': res['url'],
        'type': res['type'] ?? type,
      });
      logActivity('Mengunggah lampiran "$fileName" pada "${task['title']}"');
      notifyListeners();
    }
  }

  Future<void> removeTaskAttachment(String taskId, String attachmentId) async {
    if (!canUserEditTask(taskId)) return;
    final task = tasks.firstWhere(
      (t) => t['id'].toString() == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isEmpty) return;

    (task['attachments'] as List).removeWhere(
      (a) => a['id'].toString() == attachmentId,
    );
    notifyListeners();
    await TaskService.deleteTaskAttachment(attachmentId);
  }

  Future<void> setTaskDueDate(
    String taskId,
    String date,
    String time,
    String reminder,
    bool addMeToCard,
  ) async {
    final task = tasks.firstWhere(
      (t) => (t as Map)['id'] == taskId,
      orElse: () => <String, dynamic>{},
    );
    if (task.isNotEmpty) {
      final taskMap = task as Map;
      taskMap['dueDate'] = date;
      taskMap['dueTime'] = time;
      taskMap['reminder'] = reminder;
      taskMap['addMeToCard'] = addMeToCard;
      taskMap['dueNotified'] = false; // Reset penanda notifikasi lokal
      if (date != 'Tanggal') taskMap['date'] = date;
      notifyListeners(); // UI langsung terbuka kuncinya saat ini juga

      await TaskService.updateTaskDetails(taskId, {
        'due_date': date == 'Tanggal' ? null : date,
        'due_time': time == 'Waktu' ? null : time,
        'reminder': reminder,
        'add_me_to_card': addMeToCard,
        'due_notified': false, // Reset penanda notifikasi di Supabase
      });

      // Cek ulang jika tenggat baru berjarak < 24 jam dari sekarang
      final String boardId = taskMap['boardId']?.toString() ?? '';
      if (boardId.isNotEmpty) {
        await checkAndNotifyTaskDeadlines(boardId);
      }
    }
  }
}
