import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SpendWise Design System — Soft Minimal
// Visual contract: New folder/soft-minimal-light.html
// ═══════════════════════════════════════════════════════════════════════════

// ── Colors ──────────────────────────────────────────────────────────────────

class AppColors {
  // Light
  static const bg         = Color(0xFFFAFAF9);
  static const surface    = Color(0xFFF2F2F0);
  static const card       = Color(0xFFFFFFFF);
  static const border     = Color(0xFFE4E4DE);
  static const ink        = Color(0xFF1C1C1A);
  static const ink2       = Color(0xFF6B6B64);
  static const ink3       = Color(0xFFACACAA);
  static const accent     = Color(0xFF18181B);
  static const accentBg   = Color(0xFFF0F0EE);

  // Semantic
  static const ok         = Color(0xFF15803D);
  static const okBg       = Color(0xFFF0FDF4);
  static const danger     = Color(0xFFDC2626);
  static const dangerBg   = Color(0xFFFEF2F2);
  static const warn       = Color(0xFFD97706);
  static const warnBg     = Color(0xFFFFFBEB);

  // Category palette
  static const cat1       = Color(0xFFDC2626); // food
  static const cat2       = Color(0xFF2563EB); // transport
  static const cat3       = Color(0xFFD97706); // shopping
  static const cat4       = Color(0xFF15803D); // bills
  static const cat5       = Color(0xFF7C3AED); // entertainment

  // Dark
  static const bgDark      = Color(0xFF111110);
  static const surfaceDark = Color(0xFF1C1C1A);
  static const cardDark    = Color(0xFF242422);
  static const borderDark  = Color(0xFF2E2E2C);
  static const inkDark     = Color(0xFFFAFAF9);
  static const ink2Dark    = Color(0xFFA0A09C);
  static const ink3Dark    = Color(0xFF5A5A58);
  static const accentDark  = Color(0xFFE8E8E4);
  static const accentBgDark= Color(0xFF1C1C1A);
}

// ── Spacing ──────────────────────────────────────────────────────────────────

class AppSpacing {
  static const s2  = 2.0;
  static const s4  = 4.0;
  static const s6  = 6.0;
  static const s8  = 8.0;
  static const s10 = 10.0;
  static const s12 = 12.0;
  static const s14 = 14.0;
  static const s16 = 16.0; // standard page edge inset
  static const s18 = 18.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s48 = 48.0;
}

// ── Radius ───────────────────────────────────────────────────────────────────

class AppRadius {
  static const r6  = 6.0;
  static const r8  = 8.0;  // chips, keypad, icon tiles
  static const r10 = 10.0; // transaction rows, search
  static const r12 = 12.0; // list cards, budget bars
  static const r16 = 16.0; // hero cards
  static const pill= 8.0;  // filter chips, segmented controls
  static const fab = 12.0; // FAB
}

// ── Typography ───────────────────────────────────────────────────────────────

class AppText {
  // Sizes
  static const heroNumber  = 38.0;
  static const bigNumber   = 48.0;
  static const screenTitle = 22.0;
  static const sectionTitle= 15.0;
  static const cardTitle   = 12.5;
  static const rowTitle    = 12.0;
  static const body        = 12.0;
  static const label       = 11.0;
  static const tiny        = 9.5;
  static const tinier      = 9.0;
  static const numMid      = 15.0;
  static const numSmall    = 12.5;

  // Weights
  static const regular = FontWeight.w400;
  static const medium  = FontWeight.w500;
  static const semibold= FontWeight.w600;
  static const bold    = FontWeight.w700;
  static const extrabold = FontWeight.w800;

  // Styles — Plus Jakarta Sans (UI)
  static TextStyle display(Color color) => GoogleFonts.plusJakartaSans(
    fontSize: heroNumber, fontWeight: semibold,
    letterSpacing: -0.045 * heroNumber, color: color,
  );

  static TextStyle heading(Color color) => GoogleFonts.plusJakartaSans(
    fontSize: screenTitle, fontWeight: bold,
    letterSpacing: -0.03 * screenTitle, color: color,
  );

  static TextStyle title(Color color) => GoogleFonts.plusJakartaSans(
    fontSize: sectionTitle, fontWeight: bold, color: color,
  );

  static TextStyle cardTitleStyle(Color color) => GoogleFonts.plusJakartaSans(
    fontSize: cardTitle, fontWeight: semibold, color: color,
  );

  static TextStyle bodyStyle(Color color) => GoogleFonts.plusJakartaSans(
    fontSize: body, fontWeight: medium, color: color,
  );

  static TextStyle labelStyle(Color color) => GoogleFonts.plusJakartaSans(
    fontSize: label, fontWeight: medium, color: color,
  );

  // Styles — IBM Plex Mono (numbers, codes)
  static TextStyle mono(double size, FontWeight weight, Color color) =>
    GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: weight, color: color);

  static TextStyle monoHero(Color color) => GoogleFonts.ibmPlexMono(
    fontSize: heroNumber, fontWeight: semibold,
    letterSpacing: -0.045 * heroNumber, color: color,
  );

  static TextStyle monoBig(Color color) => GoogleFonts.ibmPlexMono(
    fontSize: bigNumber, fontWeight: semibold,
    letterSpacing: -0.045 * bigNumber, color: color,
  );

  static TextStyle monoAmount(Color color, {double size = numSmall}) =>
    GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: semibold, color: color);

  static TextStyle monoLabel(Color color) => GoogleFonts.ibmPlexMono(
    fontSize: tinier, fontWeight: medium, color: color,
    letterSpacing: 0.10 * tinier,
  );

  static TextStyle monoCaption(Color color) => GoogleFonts.ibmPlexMono(
    fontSize: tiny, fontWeight: regular, color: color,
  );
}

// ── Shadows ───────────────────────────────────────────────────────────────────

class AppShadow {
  // No shadow on cards — border carries visual weight
  static const none = <BoxShadow>[];

  // FAB only
  static List<BoxShadow> get fab => const [
    BoxShadow(color: Color(0x4018181B), blurRadius: 16, offset: Offset(0, 4)),
  ];
}

// ── Theme Builders ────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.ink2,
        surface: AppColors.card,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSurface: AppColors.ink,
        outline: AppColors.border,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppText.title(AppColors.ink),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.r12)),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border, thickness: 1, space: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.ink3,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.fab)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12, vertical: AppSpacing.s10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r10),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r10),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: AppText.bodyStyle(AppColors.ink3),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.ink,
        unselectedLabelColor: AppColors.ink3,
        indicatorColor: AppColors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accent,
        labelStyle: AppText.labelStyle(AppColors.ink2),
        side: const BorderSide(color: AppColors.border, width: 1),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10, vertical: AppSpacing.s4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppText.bodyStyle(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentDark,
        secondary: AppColors.ink2Dark,
        surface: AppColors.cardDark,
        error: AppColors.danger,
        onPrimary: AppColors.bgDark,
        onSurface: AppColors.inkDark,
        outline: AppColors.borderDark,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.inkDark,
        displayColor: AppColors.inkDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.inkDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppText.title(AppColors.inkDark),
        iconTheme: const IconThemeData(color: AppColors.inkDark),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.r12)),
          side: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark, thickness: 1, space: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.accentDark,
        unselectedItemColor: AppColors.ink3Dark,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentDark,
        foregroundColor: AppColors.bgDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.fab)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12, vertical: AppSpacing.s10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r10),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r10),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r10),
          borderSide: const BorderSide(color: AppColors.accentDark, width: 1.5),
        ),
        hintStyle: AppText.bodyStyle(AppColors.ink3Dark),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.inkDark,
        unselectedLabelColor: AppColors.ink3Dark,
        indicatorColor: AppColors.accentDark,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.borderDark,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardDark,
        contentTextStyle: AppText.bodyStyle(AppColors.inkDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

// ── Context helpers ───────────────────────────────────────────────────────────

extension AppColorsContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get cBg      => isDark ? AppColors.bgDark      : AppColors.bg;
  Color get cSurface => isDark ? AppColors.surfaceDark  : AppColors.surface;
  Color get cCard    => isDark ? AppColors.cardDark     : AppColors.card;
  Color get cBorder  => isDark ? AppColors.borderDark   : AppColors.border;
  Color get cInk     => isDark ? AppColors.inkDark      : AppColors.ink;
  Color get cInk2    => isDark ? AppColors.ink2Dark     : AppColors.ink2;
  Color get cInk3    => isDark ? AppColors.ink3Dark     : AppColors.ink3;
  Color get cAccent  => isDark ? AppColors.accentDark   : AppColors.accent;
  Color get cAccentBg=> isDark ? AppColors.accentBgDark : AppColors.accentBg;
}
