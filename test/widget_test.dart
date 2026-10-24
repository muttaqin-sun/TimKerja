import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timkerja/main.dart';
import 'package:timkerja/screens/settings/appearance_screen.dart';
import 'package:timkerja/screens/splash_screen.dart';
import 'package:timkerja/theme/app_theme.dart';

void main() {
  testWidgets('App renders SplashScreen successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const TimkerjaApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.textContaining('Kerja bareng'), findsOneWidget);
  });

  testWidgets('AppearanceScreen toggles dark mode across the app', (WidgetTester tester) async {
    // Reset to light mode initially
    AppThemeController.instance.setThemeMode(ThemeMode.light);
    expect(AppThemeController.instance.isDarkMode, false);
    expect(AppColors.isDarkMode, false);
    expect(AppColors.background, const Color(0xFFFFFFFF));

    await tester.pumpWidget(
      const MaterialApp(
        home: AppearanceScreen(),
      ),
    );

    // Tap on 'Gelap'
    final gelapFinder = find.text('Gelap');
    expect(gelapFinder, findsOneWidget);
    await tester.tap(gelapFinder);
    await tester.pumpAndSettle();

    // Verify dark mode is now enabled centrally
    expect(AppThemeController.instance.isDarkMode, true);
    expect(AppColors.isDarkMode, true);
    expect(AppColors.background, const Color(0xFF0F172A));
    expect(AppColors.surface, const Color(0xFF1E293B));
    expect(AppColors.textPrimary, const Color(0xFFF8FAFC));

    // Tap back on 'Terang'
    final terangFinder = find.text('Terang');
    expect(terangFinder, findsOneWidget);
    await tester.tap(terangFinder);
    await tester.pumpAndSettle();

    // Verify switched back to light mode
    expect(AppThemeController.instance.isDarkMode, false);
    expect(AppColors.isDarkMode, false);
    expect(AppColors.background, const Color(0xFFFFFFFF));
    expect(AppColors.surface, const Color(0xFFFFFFFF));
    expect(AppColors.textPrimary, const Color(0xFF0F172A));
  });
}
