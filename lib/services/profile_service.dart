import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart'; // Tempat inisialisasi supabase client global

class ProfileService {
  /// Mengambil data profil user berdasarkan ID (UUID dari Auth)
  static Future<dynamic> getProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      print('Error fetch profile: $e');
      return null;
    }
  }

  /// Memperbarui nama profil
  static Future<bool> updateProfileName(String userId, String newName) async {
    try {
      await supabase
          .from('profiles')
          .update({'name': newName})
          .eq('id', userId);
      return true;
    } catch (e) {
      print('Error update profile: $e');
      return false;
    }
  }
}
