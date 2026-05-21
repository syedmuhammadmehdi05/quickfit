import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand colours (same in both themes) ─────────────────────────────
  static const Color primary     = Color(0xFF1D9E75);
  static const Color primaryDark = Color(0xFF0F6E56);
  static const Color primaryLight= Color(0xFFE1F5EE);
  static const Color accent      = Color(0xFFBA7517);
  static const Color accentLight = Color(0xFFFAEEDA);
  static const Color coral       = Color(0xFFD85A30);
  static const Color coralLight  = Color(0xFFFAECE7);
  static const Color purple      = Color(0xFF7F77DD);
  static const Color purpleLight = Color(0xFFEEEDFE);

  // ── Light-mode static constants (kept for const widgets) ────────────
  static const Color surface       = Color(0xFFF8F9FA);
  static const Color cardBg        = Colors.white;
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint      = Color(0xFF9CA3AF);
  static const Color border        = Color(0xFFE5E7EB);

  // ── Dark-mode static constants ───────────────────────────────────────
  static const Color _darkSurface       = Color(0xFF0D0D0D);
  static const Color _darkCardBg        = Color(0xFF1A1A1A);
  static const Color _darkBorder        = Color(0xFF2A2A2A);
  static const Color _darkTextPrimary   = Color(0xFFF1F5F9);
  static const Color _darkTextSecondary = Color(0xFF94A3B8);
  static const Color _darkTextHint      = Color(0xFF64748B);

  // ── Dynamic helpers (use these in non-const widget trees) ───────────
  static Color cardBgOf(BuildContext ctx) =>
      _isDark(ctx) ? _darkCardBg : cardBg;
  static Color surfaceOf(BuildContext ctx) =>
      _isDark(ctx) ? _darkSurface : surface;
  static Color borderOf(BuildContext ctx) =>
      _isDark(ctx) ? _darkBorder : border;
  static Color textPrimaryOf(BuildContext ctx) =>
      _isDark(ctx) ? _darkTextPrimary : textPrimary;
  static Color textSecondaryOf(BuildContext ctx) =>
      _isDark(ctx) ? _darkTextSecondary : textSecondary;
  static Color textHintOf(BuildContext ctx) =>
      _isDark(ctx) ? _darkTextHint : textHint;

  static bool _isDark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;

  // ── Light ThemeData ──────────────────────────────────────────────────
  static ThemeData get lightTheme => _build(Brightness.light);

  // ── Dark ThemeData ───────────────────────────────────────────────────
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg     = isDark ? _darkSurface  : surface;
    final card   = isDark ? _darkCardBg   : cardBg;
    final brd    = isDark ? _darkBorder   : border;
    final txtP   = isDark ? _darkTextPrimary   : textPrimary;
    final txtS   = isDark ? _darkTextSecondary : textSecondary;
    final txtH   = isDark ? _darkTextHint      : textHint;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
      ).copyWith(
        primary: primary,
        secondary: accent,
        surface: bg,
        onSurface: txtP,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme,
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: txtP),
        titleTextStyle: GoogleFonts.poppins(
          color: txtP,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: brd, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF222222) : surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: coral),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: txtS),
        hintStyle: TextStyle(color: txtH),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? _darkCardBg : surface,
        selectedColor: primaryLight,
        side: BorderSide(color: brd),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: GoogleFonts.poppins(fontSize: 13),
      ),
      dividerTheme: DividerThemeData(color: brd, thickness: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primary,
        unselectedItemColor: txtH,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
