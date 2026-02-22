import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application-wide Material 3 theme.
class AppTheme {
  AppTheme._();

  /// Primary brand seed — rose/pink.
  static const Color _seed = Color(0xFFE91E8C);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );

    // GoogleFonts.poppinsTextTheme may do a network fetch on first run.
    // Wrap in try-catch so a CDN failure never blocks rendering.
    TextTheme poppinsTextTheme;
    try {
      poppinsTextTheme = GoogleFonts.poppinsTextTheme(base.textTheme);
    } catch (_) {
      poppinsTextTheme = base.textTheme;
    }

    return base.copyWith(
      textTheme: poppinsTextTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withAlpha(128),
          ),
        ),
        color: scheme.surfaceContainerLow,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
