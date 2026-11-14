import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Tempat inisialisasi supabase client global

class ProfileService {
  /// Mengambil data profil user berdasarkan ID (UUID dari Auth)
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
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
      return false;
    }
  }

  /// Memperbarui kata sandi user aktif
  static Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Upload foto avatar ke Supabase Storage dan update kolom avatar_url di profiles
  static Future<String?> uploadAvatar({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last.toLowerCase();
      final fileName = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Upload ke bucket 'avatars'
      await supabase.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Ambil Public URL gambar
      final imageUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      // Update kolom avatar_url di tabel profiles
      await supabase
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', userId);

      return imageUrl;
    } catch (e) {
      return null;
    }
  }
}
