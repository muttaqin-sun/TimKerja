import '../main.dart';

class NotificationService {
  /// Ambil daftar notifikasi milik user yang sedang login
  static Future<List<Map<String, dynamic>>> fetchUserNotifications(
    String userId,
  ) async {
    try {
      final res = await supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print('ERROR fetchUserNotifications: $e');
      return [];
    }
  }

  /// Kirim notifikasi ke satu user
  static Future<void> sendNotification({
    required String targetUserId,
    required String title,
    required String subtitle,
    required String type, // 'Mentions' | 'Assignments' | 'Due Dates' | 'Polls'
    String priority = 'Medium', // 'High' | 'Medium' | 'Low'
    String? boardId,
    String? referenceId,
  }) async {
    try {
      await supabase.from('notifications').insert({
        'user_id': targetUserId,
        'title': title,
        'subtitle': subtitle,
        'type': type,
        'priority': priority,
        'is_read': false,
        'board_id': boardId,
        'reference_id': referenceId,
      });
    } catch (e) {
      print('ERROR sendNotification: $e');
    }
  }

  /// Kirim notifikasi massal ke banyak user sekaligus
  static Future<void> sendBulkNotifications({
    required List<String> targetUserIds,
    required String title,
    required String subtitle,
    required String type,
    String priority = 'Medium',
    String? boardId,
    String? referenceId,
  }) async {
    if (targetUserIds.isEmpty) return;
    try {
      final payloads = targetUserIds
          .toSet()
          .map((uid) => {
                'user_id': uid,
                'title': title,
                'subtitle': subtitle,
                'type': type,
                'priority': priority,
                'is_read': false,
                'board_id': boardId,
                'reference_id': referenceId,
              })
          .toList();

      await supabase.from('notifications').insert(payloads);
    } catch (e) {
      print('ERROR sendBulkNotifications: $e');
    }
  }

  static Future<void> markAsRead(String notifId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notifId);
    } catch (e) {
      print('ERROR markAsRead: $e');
    }
  }

  static Future<void> markAllAsRead(String userId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print('ERROR markAllAsRead: $e');
    }
  }

  static Future<void> deleteNotification(String notifId) async {
    try {
      await supabase.from('notifications').delete().eq('id', notifId);
    } catch (e) {
      print('ERROR deleteNotification: $e');
    }
  }
}