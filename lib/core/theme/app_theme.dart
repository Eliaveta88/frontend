import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Темы приложения: светлая — нейтральная; тёмная — **OLED**: фон почти #000, без «зелёного» surface tint.
class AppTheme {
  AppTheme._();

  /// Единые отступы для списков и форм на широких экранах.
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(28, 28, 28, 36);

  /// Тёмная тема: «шахматка» строк `#000000` / `#1C1C1C` (читаемость OLED).
  static const tableStripeDarkA = Color(0xFF000000);
  static const tableStripeDarkB = Color(0xFF1C1C1C);

  /// Светлая тема: мягкое чередование без резкого контраста.
  static const tableStripeLightA = Color(0xFFFFFFFF);
  static const tableStripeLightB = Color(0xFFF0F2F4);

  /// Фон строки [DataRow] в стиле шахматной доски; hover/selected слегка подсвечиваются.
  static WidgetStateProperty<Color?> dataRowStripe(int index, ColorScheme scheme) {
    final light = scheme.brightness == Brightness.light;
    final a = light ? tableStripeLightA : tableStripeDarkA;
    final b = light ? tableStripeLightB : tableStripeDarkB;
    final base = index.isEven ? a : b;
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Color.alphaBlend(scheme.primary.withAlpha(40), base);
      }
      if (states.contains(WidgetState.hovered)) {
        return Color.alphaBlend(
          (light ? Colors.black : Colors.white).withAlpha(light ? 16 : 22),
          base,
        );
      }
      return base;
    });
  }

  static const _seed = Color(0xFF00897B);

  /// Почти идеальный чёрный и ступени «подъёма» для AMOLED (минимальная засветка пикселей).
  static const _oledSurface = Color(0xFF000000);
  static const _oledContainerLowest = Color(0xFF000000);
  static const _oledContainerLow = Color(0xFF070707);
  static const _oledContainer = Color(0xFF0C0C0C);
  static const _oledContainerHigh = Color(0xFF121212);
  static const _oledContainerHighest = Color(0xFF181818);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    return _build(scheme);
  }

  static ThemeData dark() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    final scheme = baseScheme.copyWith(
      surface: _oledSurface,
      surfaceDim: _oledContainerLow,
      surfaceBright: _oledContainerHigh,
      surfaceContainerLowest: _oledContainerLowest,
      surfaceContainerLow: _oledContainerLow,
      surfaceContainer: _oledContainer,
      surfaceContainerHigh: _oledContainerHigh,
      surfaceContainerHighest: _oledContainerHighest,
      surfaceTint: Colors.transparent,
      outline: const Color(0xFF383838),
      outlineVariant: const Color(0xFF2A2A2A),
      shadow: Colors.black,
      scrim: Color(0xCC000000),
    );
    return _build(scheme);
  }

  static TextTheme _typography(TextTheme base, ColorScheme scheme) {
    final on = scheme.onSurface;
    final onVar = scheme.onSurfaceVariant;
    TextStyle? t(TextStyle? s, {
      double? fontSize,
      double? height,
      FontWeight? fontWeight,
      double? letterSpacing,
      Color? color,
    }) {
      return s?.copyWith(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color ?? s.color ?? on,
      );
    }

    return base.copyWith(
      displayLarge: t(base.displayLarge,
          fontSize: 57, height: 1.12, fontWeight: FontWeight.w400, letterSpacing: -0.25),
      displayMedium: t(base.displayMedium,
          fontSize: 45, height: 1.16, fontWeight: FontWeight.w400, letterSpacing: 0),
      displaySmall: t(base.displaySmall,
          fontSize: 36, height: 1.22, fontWeight: FontWeight.w400, letterSpacing: 0),
      headlineLarge: t(base.headlineLarge,
          fontSize: 32, height: 1.25, fontWeight: FontWeight.w600, letterSpacing: 0),
      headlineMedium: t(base.headlineMedium,
          fontSize: 28, height: 1.29, fontWeight: FontWeight.w600, letterSpacing: 0),
      headlineSmall: t(base.headlineSmall,
          fontSize: 24, height: 1.33, fontWeight: FontWeight.w600, letterSpacing: 0),
      titleLarge: t(base.titleLarge,
          fontSize: 22, height: 1.27, fontWeight: FontWeight.w600, letterSpacing: 0),
      titleMedium: t(base.titleMedium,
          fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, letterSpacing: 0.15),
      titleSmall: t(base.titleSmall,
          fontSize: 14, height: 1.43, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      bodyLarge: t(base.bodyLarge,
          fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, letterSpacing: 0.15),
      bodyMedium: t(base.bodyMedium,
          fontSize: 14, height: 1.43, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      bodySmall: t(base.bodySmall,
          fontSize: 12, height: 1.33, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: onVar),
      labelLarge: t(base.labelLarge,
          fontSize: 14, height: 1.43, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: t(base.labelMedium,
          fontSize: 12, height: 1.33, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelSmall: t(base.labelSmall,
          fontSize: 11, height: 1.45, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }

  static ThemeData _build(ColorScheme scheme) {
    final isLight = scheme.brightness == Brightness.light;
    final baseRaw = GoogleFonts.plusJakartaSansTextTheme(
      isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme,
    );
    final base = _typography(baseRaw, scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: base,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: base.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withAlpha(isLight ? 80 : 100),
          ),
        ),
        color: isLight ? scheme.surface : scheme.surfaceContainerLow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isLight
            ? scheme.surfaceContainerLowest
            : scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        minExtendedWidth: 220,
        selectedIconTheme:
            IconThemeData(color: scheme.onPrimaryContainer, size: 24),
        unselectedIconTheme:
            IconThemeData(color: scheme.onSurfaceVariant, size: 24),
        labelType: NavigationRailLabelType.all,
        selectedLabelTextStyle: base.labelLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: base.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        minVerticalPadding: 12,
        titleTextStyle: base.titleSmall?.copyWith(color: scheme.onSurface),
        subtitleTextStyle: base.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withAlpha(isLight ? 100 : 140),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant.withAlpha(60)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: base.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(120, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(120, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(80, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: scheme.outlineVariant.withAlpha(80)),
        labelStyle: base.labelMedium,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(
          scheme.surfaceContainerHighest.withAlpha(isLight ? 80 : 72),
        ),
        headingTextStyle: base.titleSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: base.bodyMedium?.copyWith(color: scheme.onSurface),
        horizontalMargin: 20,
        columnSpacing: 20,
        dividerThickness: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        width: 400,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withAlpha(60),
        thickness: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: base.bodySmall?.copyWith(color: scheme.onInverseSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(
          scheme.surfaceContainerHighest.withAlpha(isLight ? 100 : 120),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: scheme.outlineVariant.withAlpha(60)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
