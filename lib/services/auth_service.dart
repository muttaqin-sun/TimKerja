import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class AuthService {
  /// Sign Up User Baru
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );
  }

  /// Sign In Email & Password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Log Out
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Ambil User yang sedang login
  static User? get currentUser => supabase.auth.currentUser;

  /// Cek apakah ada sesi aktif
  static bool get isAuthenticated => supabase.auth.currentSession != null;
}
