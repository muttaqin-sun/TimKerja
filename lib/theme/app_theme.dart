import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Theme Mode Controller for Timkerja app.
/// Allows toggling and observing light/dark theme anywhere in the app.
class AppThemeController extends ChangeNotifier {
  static final AppThemeController instance = AppThemeController._internal();
  AppThemeController._internal();

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }
}

/// Centralized Design System & Theme configuration for Timkerja app.
/// All colors, typography, shapes, shadows, and ThemeData are unified in this single file.
class AppColors {
  /// Reactive dark mode flag synced with the centralized AppThemeController.
  static bool get isDarkMode => AppThemeController.instance.isDarkMode;

  // Brand Teal / Tosca (Matching the uploaded design screenshot)
  static const Color primary = Color(0xFF00A896);
  static const Color primaryDark = Color(0xFF007A6C);
  static const Color primaryLight = Color(0xFF4DB6AC);

  static Color get primarySurface =>
      isDarkMode ? const Color(0xFF0D2825) : const Color(0xFFE6F7F5);
  static Color get primarySurfaceSubtle =>
      isDarkMode ? const Color(0xFF0A201E) : const Color(0xFFF0FAF8);
  static Color get primaryContainer =>
      isDarkMode ? const Color(0xFF133B36) : const Color(0xFFCCF0EB);

  // Splash Gradient Colors (Teal tones)
  static const Color gradientStart = Color(0xFF26A69A);
  static const Color gradientMiddle = Color(0xFF00A896);
  static const Color gradientEnd = Color(0xFF00897B);

  // Decorative Shapes / Soft Top Blobs
  static const Color blobTeal = Color(0x2600A896); // ~15% opacity
  static const Color blobTealSubtle = Color(0x1400A896); // ~8% opacity
  static const Color waveOverlay1 = Color(0x334DB6AC);
  static const Color waveOverlay2 = Color(0x2626A69A);
  static const Color waveOverlay3 = Color(0x1A00897B);

  // Backgrounds & Neutrals (Clean white & dark slate)
  static Color get background =>
      isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
  static Color get backgroundLight =>
      isDarkMode ? const Color(0xFF162032) : const Color(0xFFF7FCFB);
  static Color get surface =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
  static Color get surfaceMuted =>
      isDarkMode ? const Color(0xFF243247) : const Color(0xFFF2F9F8);
  static Color get surfaceCard =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  // Text Colors
  static Color get textPrimary =>
      isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textSecondary =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get textMuted =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textLightMuted = Color(0xCCFFFFFF);

  // Borders & Dividers
  static Color get border =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get borderLight =>
      isDarkMode ? const Color(0xFF243247) : const Color(0xFFEDF2F7);
  static const Color borderFocused = Color(0xFF00A896);
  static Color get divider =>
      isDarkMode ? const Color(0xFF243247) : const Color(0xFFEEF2F6);

  // Priority Badges (Matching Screenshot: High, Medium, Low)
  static Color get priorityHighBg =>
      isDarkMode ? const Color(0xFF3B1818) : const Color(0xFFFEE2E2);
  static Color get priorityHighText =>
      isDarkMode ? const Color(0xFFF87171) : const Color(0xFFEF4444);

  static Color get priorityMediumBg =>
      isDarkMode ? const Color(0xFF3B2314) : const Color(0xFFFFEDD5);
  static Color get priorityMediumText =>
      isDarkMode ? const Color(0xFFFB923C) : const Color(0xFFF97316);

  static Color get priorityLowBg =>
      isDarkMode ? const Color(0xFF143321) : const Color(0xFFDCFCE7);
  static Color get priorityLowText =>
      isDarkMode ? const Color(0xFF34D399) : const Color(0xFF10B981);

  // Category / Board Card Icon Accents (Matching Screenshot: Kuliah-TI, Project A, Desain UI)
  static Color get boardBlueBg =>
      isDarkMode ? const Color(0xFF0F2942) : const Color(0xFFE0F2FE);
  static const Color boardBlueIcon = Color(0xFF0284C7);

  static Color get boardGreenBg =>
      isDarkMode ? const Color(0xFF103423) : const Color(0xFFDCFCE7);
  static const Color boardGreenIcon = Color(0xFF16A34A);

  static Color get boardPurpleBg =>
      isDarkMode ? const Color(0xFF2E1C44) : const Color(0xFFF3E8FF);
  static const Color boardPurpleIcon = Color(0xFF9333EA);

  // Functional / Status
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Kanban / Badge accents
  static const Color todoBadge = Color(0xFF64748B);
  static const Color inProgressBadge = Color(0xFF0284C7);
  static const Color doneBadge = Color(0xFF00A896);
  static const Color avatar1 = Color(0xFF00A896);
  static const Color avatar2 = Color(0xFF38BDF8);
  static const Color avatar3 = Color(0xFF34D399);
  static const Color avatar4 = Color(0xFFFBBF24);
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.gradientStart,
      AppColors.gradientMiddle,
      AppColors.gradientEnd,
    ],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF26A69A), Color(0xFF00A896), Color(0xFF00897B)],
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xE6FFFFFF), Color(0xCCFFFFFF), Color(0xB3FFFFFF)],
  );

  static const LinearGradient authHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF26A69A), Color(0xFF00A896)],
  );

  static const LinearGradient softBlobGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x3300A896),
      Color(0x0D00A896),
    ],
  );
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double pill = 999.0;

  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius roundedPill = BorderRadius.all(
    Radius.circular(pill),
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 16.0,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(14.0);
}

class AppShadows {
  static const BoxShadow soft = BoxShadow(
    color: Color(0x0A00A896),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow card = BoxShadow(
    color: Color(0x08000000),
    blurRadius: 10,
    offset: Offset(0, 2),
  );

  static const BoxShadow button = BoxShadow(
    color: Color(0x3300A896),
    blurRadius: 16,
    offset: Offset(0, 6),
  );

  static const BoxShadow floatingBadge = BoxShadow(
    color: Color(0x1A00A896),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const BoxShadow subtleBorder = BoxShadow(
    color: Color(0x05000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  );
}

class AppTextStyles {
  // Base font family getter with graceful fallback
  static TextStyle _font({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    try {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'sans-serif',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }
  }

  // Display & Headings
  static TextStyle get splashTitle => _font(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textLight,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static TextStyle get splashSubtitle => _font(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textLightMuted,
    height: 1.45,
  );

  static TextStyle get brandTitleLight => _font(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textLight,
    letterSpacing: -0.5,
  );

  static TextStyle get brandTitleDark => _font(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get authTitle => _font(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  static TextStyle get authSubtitle => _font(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  // Form & Body
  static TextStyle get inputLabel => _font(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get inputText => _font(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get inputHint => _font(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static TextStyle get buttonLarge => _font(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.2,
  );

  static TextStyle get buttonSocial => _font(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle get linkText => _font(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get bodyMuted => _font(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get dividerText => _font(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  // App & Screen Navigation Typography (Matching Screenshot)
  static TextStyle get screenTitle => _font(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get sectionTitle => _font(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get sectionAction => _font(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static TextStyle get cardTitle => _font(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get cardSubtitle => _font(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static TextStyle get badgeText => _font(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get filterChipText => _font(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get statNumber => _font(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle get statLabel => _font(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

/// Complete AppTheme that can be supplied directly to MaterialApp
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textLight,
        secondary: AppColors.primaryDark,
        onSecondary: AppColors.textLight,
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF0F172A),
        error: AppColors.error,
        onError: AppColors.textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF94A3B8),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFFFFFFFF),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEDF2F7),
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.roundedPill,
          ),
          textStyle: AppTextStyles.buttonLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F172A),
          backgroundColor: const Color(0xFFFFFFFF),
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.roundedPill,
          ),
          textStyle: AppTextStyles.buttonSocial,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF2F9F8),
        hintStyle: AppTextStyles.inputHint,
        prefixIconColor: const Color(0xFF94A3B8),
        suffixIconColor: const Color(0xFF94A3B8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(
            color: AppColors.borderFocused,
            width: 1.8,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textLight),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.textLight,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.textLight,
        surface: Color(0xFF1E293B),
        onSurface: Color(0xFFF8FAFC),
        error: AppColors.error,
        onError: AppColors.textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFF8FAFC)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF64748B),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E293B),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF243247),
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.roundedPill,
          ),
          textStyle: AppTextStyles.buttonLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF8FAFC),
          backgroundColor: const Color(0xFF1E293B),
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: Color(0xFF334155), width: 1.2),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.roundedPill,
          ),
          textStyle: AppTextStyles.buttonSocial,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF243247),
        hintStyle: AppTextStyles.inputHint,
        prefixIconColor: const Color(0xFF64748B),
        suffixIconColor: const Color(0xFF64748B),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: Color(0xFF334155), width: 1.2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: Color(0xFF334155), width: 1.2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(
            color: AppColors.borderFocused,
            width: 1.8,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textLight),
        side: const BorderSide(color: Color(0xFF334155), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
