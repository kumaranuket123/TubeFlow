import 'package:flutter/material.dart';

/// YouTube-style light and dark themes: white / near-black surfaces, flat
/// app bars, YouTube red for primary actions, pill-shaped buttons.
class AppTheme {
  AppTheme._();

  static const youtubeRed = Color(0xFFFF0000);
  static const _ink = Color(0xFF0F0F0F);
  static const _darkSurface = Color(0xFF212121);

  static final light = _build(
    ColorScheme.light(
      primary: youtubeRed,
      onPrimary: Colors.white,
      secondary: _ink,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: _ink,
      surfaceContainerHighest: const Color(0xFFF2F2F2),
      secondaryContainer: const Color(0xFFF2F2F2),
      onSecondaryContainer: _ink,
      tertiaryContainer: const Color(0xFFFFE9E9),
      onTertiaryContainer: _ink,
      error: const Color(0xFFCC0000),
      outlineVariant: const Color(0xFFE5E5E5),
    ),
  );

  static final dark = _build(
    ColorScheme.dark(
      primary: youtubeRed,
      onPrimary: Colors.white,
      secondary: Colors.white,
      onSecondary: _ink,
      surface: _ink,
      onSurface: Colors.white,
      surfaceContainerHighest: _darkSurface,
      secondaryContainer: const Color(0xFF272727),
      onSecondaryContainer: Colors.white,
      tertiaryContainer: const Color(0xFF3A1A1A),
      onTertiaryContainer: Colors.white,
      error: const Color(0xFFFF6B6B),
      outlineVariant: const Color(0xFF303030),
    ),
  );

  static ThemeData _build(ColorScheme scheme) {
    const pill = StadiumBorder();
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: pill,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: pill,
          side: BorderSide(color: scheme.outlineVariant),
          foregroundColor: scheme.onSurface,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: pill, foregroundColor: scheme.onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: const StadiumBorder(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? scheme.onPrimary : null),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? scheme.primary : null),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? scheme.primary : null),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.brightness == Brightness.dark
            ? _darkSurface
            : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF212121),
        contentTextStyle: TextStyle(
          color: scheme.brightness == Brightness.dark ? _ink : Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }
}
