import '../main.dart';

class BoardService {
  /// Mengambil daftar board yang relevan dengan user dari Supabase
  /// - Jika 'Pembuat Board': mengambil semua board yang dia buat atau dia ikuti
  /// - Jika 'Anggota': mengambil semua board tempat dia terdaftar di board_members
  static Future<List<Map<String, dynamic>>> fetchUserBoards({
    required String userId,
    required String role,
  }) async {
    try {
      // 1. Ambil daftar board_id yang user ikuti dari board_members
      final memberRows = await supabase
          .from('board_members')
          .select('board_id, role')
          .eq('user_id', userId);

      final List<dynamic> memberList = memberRows as List<dynamic>;
      final memberBoardIds = memberList.map((m) => m['board_id'].toString()).toSet();

      // 2. Query tabel boards
      // Ambil board tempat user menjadi creator ATAU anggota
      var query = supabase
          .from('boards')
          .select('*, profiles!boards_created_by_fkey(name, email, avatar_url), board_members(user_id, role, profiles(name, avatar_color)), board_lists(*), tasks(id)')
          .order('created_at', ascending: false);

      final List<dynamic> allBoardsData = await query;

      // Filter board yang relevan
      final List<Map<String, dynamic>> result = [];
      for (var b in allBoardsData) {
        final boardId = b['id'].toString();
        final createdBy = b['created_by']?.toString();
        final isCreator = createdBy == userId;
        final isMember = memberBoardIds.contains(boardId);

        // Jika dia pembuat atau anggota dari board ini
        if (isCreator || isMember) {
          result.add(Map<String, dynamic>.from(b));
        }
      }

      return result;
    } catch (e) {
      // Fallback: query sederhana jika foreign key name berbeda
      try {
        final fallbackBoards = await supabase
            .from('boards')
            .select('*, board_members(user_id, role), board_lists(*)')
            .order('created_at', ascending: false);

        return List<Map<String, dynamic>>.from(fallbackBoards);
      } catch (_) {
        return [];
      }
    }
  }

  /// Membuat Board Baru
  static Future<Map<String, dynamic>?> createBoard({
    required String title,
    required String desc,
    required int color,
    required String privacy,
    required String userId,
  }) async {
    try {
      final res = await supabase
          .from('boards')
          .insert({
            'title': title,
            'description': desc,
            'color': color,
            'privacy': privacy,
            'created_by': userId,
          })
          .select()
          .single();

      final boardId = res['id'];

      // Pastikan member owner tercatat
      try {
        await supabase.from('board_members').upsert({
          'board_id': boardId,
          'user_id': userId,
          'role': 'Owner',
        });
      } catch (_) {}

      return Map<String, dynamic>.from(res);
    } catch (e) {
      return null;
    }
  }

  /// Bergabung ke Board lewat Kode Unik
  static Future<Map<String, dynamic>> joinBoardByCode({
    required String code,
    required String userId,
  }) async {
    try {
      final cleanCode = code.trim().toUpperCase();

      // Cari board dengan kode tersebut
      final boardRes = await supabase
          .from('boards')
          .select()
          .eq('code', cleanCode)
          .maybeSingle();

      if (boardRes == null) {
        return {'success': false, 'message': 'Kode board tidak ditemukan.'};
      }

      final boardId = boardRes['id'];

      // Cek apakah user sudah terdaftar di board tersebut
      final existingMember = await supabase
          .from('board_members')
          .select()
          .eq('board_id', boardId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        return {'success': false, 'message': 'Anda sudah terdaftar di board ini.'};
      }

      // Tambahkan user sebagai member
      await supabase.from('board_members').insert({
        'board_id': boardId,
        'user_id': userId,
        'role': 'Member',
      });

      return {'success': true, 'board': boardRes};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan saat bergabung: $e'};
    }
  }

  /// Update Pengaturan Board (Judul, Deskripsi, Privasi)
  static Future<bool> updateBoardSettings({
    required String boardId,
    required String title,
    required String desc,
    required String privacy,
  }) async {
    try {
      await supabase.from('boards').update({
        'title': title,
        'description': desc,
        'privacy': privacy,
      }).eq('id', boardId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Hapus Board Permanen
  static Future<bool> deleteBoard(String boardId) async {
    try {
      await supabase.from('boards').delete().eq('id', boardId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Keluar dari Board (khusus Anggota)
  static Future<bool> leaveBoard({
    required String boardId,
    required String userId,
  }) async {
    try {
      await supabase
          .from('board_members')
          .delete()
          .eq('board_id', boardId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
