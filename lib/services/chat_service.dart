import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class ChatService {
  /// Mengambil riwayat pesan untuk board tertentu lengkap dengan profil pengirim
  static Future<List<Map<String, dynamic>>> fetchMessages(String boardId) async {
    try {
      final res = await supabase
          .from('messages')
          .select('*, profiles(name, avatar_color, avatar_url)')
          .eq('board_id', boardId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      return [];
    }
  }

  /// Mengirim pesan baru ke board
  static Future<Map<String, dynamic>?> sendMessage({
    required String boardId,
    required String senderId,
    required String text,
    String? attachmentUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'board_id': boardId,
        'sender_id': senderId,
        'text': text,
      };
      if (attachmentUrl != null && attachmentUrl.isNotEmpty) {
        payload['attachment_url'] = attachmentUrl;
      }

      final res = await supabase
          .from('messages')
          .insert(payload)
          .select('*, profiles(name, avatar_color, avatar_url)')
          .single();

      return Map<String, dynamic>.from(res);
    } catch (e) {
      return null;
    }
  }

  /// Subscribe ke channel Realtime Supabase untuk perubahan di tabel messages pada board tertentu
  static RealtimeChannel subscribeToBoardMessages({
    required String boardId,
    required void Function(Map<String, dynamic> newRecord) onInsert,
  }) {
    final channel = supabase
        .channel('board_chat_$boardId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'board_id',
            value: boardId,
          ),
          callback: (payload) {
            onInsert(payload.newRecord);
          },
        )
        .subscribe();

    return channel;
  }
}
