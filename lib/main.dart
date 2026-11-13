import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'data/app_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Supabase Client
  await Supabase.initialize(
    url: 'https://fftzlawppqwltagfgtxu.supabase.co', // Ganti dengan URL Supabase milikmu
    anonKey: 'sb_publishable_D7oMJI_u9Q46ogTu_7b0LQ_6ulGzdgx', // Ganti dengan Anon Key milikmu
  );

  // Jika ada sesi login aktif, muat data profil user sebelum aplikasi tampil
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser != null) {
    await AppDataController.instance.loadUserProfile(currentUser.id);
  }

  runApp(const TimkerjaApp());
}

// Client global untuk diakses dengan mudah di mana saja
final supabase = Supabase.instance.client;

class TimkerjaApp extends StatelessWidget {
  const TimkerjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppThemeController.instance,
      builder: (context, _) {
        final isDark = AppThemeController.instance.isDarkMode;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
        );

        final session = supabase.auth.currentSession;

        return MaterialApp(
          title: 'Timkerja',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppThemeController.instance.themeMode,
          home: session != null
              ? const MainNavigationScreen()
              : const SplashScreen(),
        );
      },
    );
  }
}
