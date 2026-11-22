import '../main.dart';

class PollService {
  /// Ambil seluruh polling pada board tertentu beserta opsi, suara, dan profil pembuat
  static Future<List<Map<String, dynamic>>> fetchPollsByBoard(
    String boardId,
  ) async {
    try {
      final res = await supabase
          .from('polls')
          .select('''
            *,
            poll_options(id, poll_id, option_text, position),
            poll_votes(id, poll_id, option_id, user_id, voted_at)
          ''')
          .eq('board_id', boardId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print('ERROR fetchPollsByBoard [$boardId]: $e');
      return [];
    }
  }

  /// Buat polling baru beserta opsi-opsinya ke tabel polls dan poll_options
  static Future<Map<String, dynamic>?> createPoll({
    required String boardId,
    required String question,
    required List<String> options,
    required String userId,
    DateTime? dueDate,
    bool showResultBeforeVote = true,
    bool notifyOnEnd = false,
  }) async {
    try {
      // 1. Insert ke tabel polls
      final pollRes = await supabase
          .from('polls')
          .insert({
            'board_id': boardId,
            'question': question,
            'due_date': dueDate?.toUtc().toIso8601String(),
            'show_result_before_vote': showResultBeforeVote,
            'created_by': userId,
          })
          .select()
          .single();

      final String pollId = pollRes['id'].toString();

      // 2. Insert ke tabel poll_options (memakai kolom poll_id dan option_text)
      final List<Map<String, dynamic>> optionPayloads = [];
      for (int i = 0; i < options.length; i++) {
        optionPayloads.add({
          'poll_id': pollId,
          'option_text': options[i],
          'position': i,
        });
      }

      await supabase.from('poll_options').insert(optionPayloads);
      return Map<String, dynamic>.from(pollRes);
    } catch (e) {
      print('ERROR createPoll [$boardId]: $e');
      rethrow;
    }
  }

  /// Kirim atau ubah suara user pada sebuah polling
  static Future<void> castVote({
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    try {
      // Hapus suara lama user di polling ini agar 1 user = 1 pilihan aktif
      await supabase
          .from('poll_votes')
          .delete()
          .eq('poll_id', pollId)
          .eq('user_id', userId);

      // Simpan pilihan baru
      await supabase.from('poll_votes').insert({
        'poll_id': pollId,
        'option_id': optionId,
        'user_id': userId,
      });
    } catch (e) {
      print('ERROR castVote [$pollId]: $e');
      rethrow;
    }
  }

  /// Hapus polling secara permanen
  static Future<bool> deletePoll(String pollId) async {
    try {
      await supabase.from('polls').delete().eq('id', pollId);
      return true;
    } catch (e) {
      print('ERROR deletePoll [$pollId]: $e');
      return false;
    }
  }
}
