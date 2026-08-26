import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF2E9E5B);
  static const Color primaryDark = Color(0xFF1F7A46);
  static const Color background = Color(0xFFF6F8F6);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF16241C);
  static const Color textSecondary = Color(0xFF6B7A72);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x14163A28), blurRadius: 18, offset: Offset(0, 6)),
  ];

  static ThemeData get light => buildTheme();

  /// Builds the app theme. Every nested widget theme below (app bar,
  /// buttons, chips...) derives its text styles from the single [textTheme]
  /// computed here, rather than constructing fresh literal `TextStyle`s -
  /// those bake their own font family in at this point and don't pick up a
  /// later `ThemeData.copyWith(textTheme: ...)` override, which is exactly
  /// what [fontFamilyOverride] is for (used by the offline preview harness
  /// to swap in a bundled font - see lib/main_preview.dart).
  static ThemeData buildTheme({String? fontFamilyOverride}) {
    final textTheme = (fontFamilyOverride != null
            ? Typography.material2021().black.apply(fontFamily: fontFamilyOverride)
            : GoogleFonts.plusJakartaSansTextTheme())
        .apply(bodyColor: textPrimary, displayColor: textPrimary);

    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primaryDark,
        brightness: Brightness.light,
      ),
      textTheme: textTheme,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
        filled: true,
        fillColor: const Color(0xFFEFF3EF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFFEFF3EF),
        labelStyle: textTheme.labelLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE7ECE8), thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
