import '../main.dart';

class TaskService {
  /// Mengambil semua list/kolom kanban untuk board tertentu
  static Future<List<Map<String, dynamic>>> fetchBoardLists(
    String boardId,
  ) async {
    try {
      final res = await supabase
          .from('board_lists')
          .select()
          .eq('board_id', boardId)
          .order('position', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      return [];
    }
  }

  /// Membuat kolom list baru di board
  static Future<Map<String, dynamic>?> createBoardList({
    required String boardId,
    required String title,
    int position = 0,
  }) async {
    final res = await supabase
        .from('board_lists')
        .insert({'board_id': boardId, 'title': title, 'position': position})
        .select()
        .single();
    return Map<String, dynamic>.from(res);
  }

  /// Rename kolom list
  static Future<bool> renameBoardList({
    required String boardId,
    required String oldTitle,
    required String newTitle,
  }) async {
    try {
      await supabase
          .from('board_lists')
          .update({'title': newTitle})
          .eq('board_id', boardId)
          .eq('title', oldTitle);

      // Sinkronkan juga task yang ada di kolom tersebut
      await supabase
          .from('tasks')
          .update({'list_name': newTitle})
          .eq('board_id', boardId)
          .eq('list_name', oldTitle);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Hapus kolom list beserta task di dalamnya
  static Future<void> deleteBoardList({
    required String boardId,
    required String title,
  }) async {
    // 1. Hapus semua task di dalam list ini terlebih dahulu (mencegah error foreign key)
    await supabase
        .from('tasks')
        .delete()
        .eq('board_id', boardId)
        .eq('list_name', title);

    // 2. Hapus kolom list dan verifikasi dengan .select() bahwa baris benar-benar terhapus
    final deletedRows = await supabase
        .from('board_lists')
        .delete()
        .eq('board_id', boardId)
        .eq('title', title)
        .select();

    if (deletedRows.isEmpty) {
      throw Exception(
        'List "$title" tidak terhapus di database. Periksa policy RLS DELETE pada tabel board_lists.',
      );
    }
  }

  /// Kunci atau buka kunci kolom list
  static Future<bool> toggleBoardListLock({
    required String boardId,
    required String title,
    required bool isLocked,
  }) async {
    try {
      await supabase
          .from('board_lists')
          .update({'is_locked': isLocked})
          .eq('board_id', boardId)
          .eq('title', title);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mengambil semua tasks untuk board tertentu lengkap dengan subtasks dan comments
  static Future<List<Map<String, dynamic>>> fetchTasksByBoard(
    String boardId,
  ) async {
    try {
      final res = await supabase
          .from('tasks')
          .select(
            '*, subtasks(*), task_comments(*, profiles(name, avatar_color))',
          )
          .eq('board_id', boardId)
          .order('position', ascending: true)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      return [];
    }
  }

  /// Mengambil semua task yang ditugaskan ke user atau ada di board yang diikuti
  static Future<List<Map<String, dynamic>>> fetchAllUserTasks(
    String userId,
  ) async {
    try {
      // Ambil task dengan info board
      final res = await supabase
          .from('tasks')
          .select(
            '*, boards!inner(title, color board_members!inner(user_id)), subtasks(*)',
          )
          .eq('boards.board_members.user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      return [];
    }
  }

  /// Menambah task baru ke dalam kolom list
  static Future<Map<String, dynamic>?> createTask({
    required String boardId,
    required String title,
    required String listName,
    required String userId,
    int position = 0,
  }) async {
    try {
      final res = await supabase
          .from('tasks')
          .insert({
            'board_id': boardId,
            'title': title,
            'list_name': listName,
            'status': 'To Do',
            'priority': 'Low',
            'created_by': userId,
            'position': position,
            'is_done': false,
          })
          .select('*, subtasks(*), task_comments(*)')
          .single();

      print('DEBUG createTask [$boardId]: $res');
      return Map<String, dynamic>.from(res);
    } catch (e) {
      print('ERROR createTask [$boardId]: $e');
      rethrow;
    }
  }

  /// Memperbarui detail task (deskripsi, tanggal, status, cover, dll)
  static Future<bool> updateTaskDetails(
    String taskId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final res = await supabase
          .from('tasks')
          .update(updates)
          .eq('id', taskId)
          .select();
      print('DEBUG updateTaskDetails [$taskId]: updates=$updates, result=$res');
      return res.isNotEmpty;
    } catch (e) {
      print('ERROR updateTaskDetails [$taskId]: $e');
      rethrow;
    }
  }

  /// Memindahkan task ke list lain atau reorder posisi
  static Future<bool> moveTask({
    required String taskId,
    required String targetListName,
    int? position,
  }) async {
    try {
      final Map<String, dynamic> payload = {'list_name': targetListName};
      if (position != null) {
        payload['position'] = position;
      }
      final res = await supabase
          .from('tasks')
          .update(payload)
          .eq('id', taskId)
          .select();
      print('DEBUG moveTask [$taskId]: $res');
      return res.isNotEmpty;
    } catch (e) {
      print('ERROR moveTask [$taskId]: $e');
      rethrow;
    }
  }

  /// Mengubah status checklist task (selesai / belum)
  static Future<bool> toggleTaskCompletion(String taskId, bool isDone) async {
    try {
      final res = await supabase
          .from('tasks')
          .update({'is_done': isDone, 'status': isDone ? 'Done' : 'To Do'})
          .eq('id', taskId)
          .select();
      print('DEBUG toggleTaskCompletion [$taskId]: $res');
      return res.isNotEmpty;
    } catch (e) {
      print('ERROR toggleTaskCompletion [$taskId]: $e');
      rethrow;
    }
  }

  /// Menghapus task permanen
  static Future<bool> deleteTask(String taskId) async {
    try {
      final res = await supabase
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .select();
      print('DEBUG deleteTask [$taskId]: $res');
      return res.isNotEmpty;
    } catch (e) {
      print('ERROR deleteTask [$taskId]: $e');
      rethrow;
    }
  }

  /// Menambah subtask baru
  static Future<Map<String, dynamic>?> addSubtask({
    required String taskId,
    required String title,
  }) async {
    try {
      final res = await supabase
          .from('subtasks')
          .insert({'task_id': taskId, 'title': title, 'is_done': false})
          .select()
          .single();
      print('DEBUG addSubtask [$taskId]: $res');
      return Map<String, dynamic>.from(res);
    } catch (e) {
      print('ERROR addSubtask [$taskId]: $e');
      rethrow;
    }
  }

  /// Toggle centang subtask
  static Future<bool> toggleSubtask(String subtaskId, bool isDone) async {
    try {
      final res = await supabase
          .from('subtasks')
          .update({'is_done': isDone})
          .eq('id', subtaskId)
          .select();
      print('DEBUG toggleSubtask [$subtaskId]: $res');
      return res.isNotEmpty;
    } catch (e) {
      print('ERROR toggleSubtask [$subtaskId]: $e');
      rethrow;
    }
  }

  /// Menghapus subtask
  static Future<bool> deleteSubtask(String subtaskId) async {
    try {
      final res = await supabase
          .from('subtasks')
          .delete()
          .eq('id', subtaskId)
          .select();
      print('DEBUG deleteSubtask [$subtaskId]: $res');
      return res.isNotEmpty;
    } catch (e) {
      print('ERROR deleteSubtask [$subtaskId]: $e');
      rethrow;
    }
  }

  /// Menambah komentar pada task
  static Future<Map<String, dynamic>?> addComment({
    required String taskId,
    required String userId,
    required String text,
  }) async {
    try {
      final res = await supabase
          .from('task_comments')
          .insert({'task_id': taskId, 'user_id': userId, 'text': text})
          .select('*, profiles(name, avatar_color)')
          .single();
      print('DEBUG addComment [$taskId]: $res');
      return Map<String, dynamic>.from(res);
    } catch (e) {
      print('ERROR addComment [$taskId]: $e');
      rethrow;
    }
  }
}
