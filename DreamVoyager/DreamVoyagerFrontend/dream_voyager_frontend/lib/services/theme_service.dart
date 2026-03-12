import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DreamAppTheme { midnight, etherealWhite, classicDark }

class DreamThemeOption {
  const DreamThemeOption({
    required this.theme,
    required this.label,
    required this.icon,
    required this.previewColors,
  });

  final DreamAppTheme theme;
  final String label;
  final IconData icon;
  final List<Color> previewColors;
}

class DreamVoyagerPalette extends ThemeExtension<DreamVoyagerPalette> {
  const DreamVoyagerPalette({
    required this.cardElevated,
    required this.navBackground,
    required this.chartGrid,
    required this.chartGridSecondary,
    required this.chartBorder,
    required this.actionGradientStart,
    required this.actionGradientEnd,
    required this.success,
    required this.balanced,
    required this.alert,
    required this.analyticsPalette,
  });

  final Color cardElevated;
  final Color navBackground;
  final Color chartGrid;
  final Color chartGridSecondary;
  final Color chartBorder;
  final Color actionGradientStart;
  final Color actionGradientEnd;
  final Color success;
  final Color balanced;
  final Color alert;
  final List<Color> analyticsPalette;

  @override
  DreamVoyagerPalette copyWith({
    Color? cardElevated,
    Color? navBackground,
    Color? chartGrid,
    Color? chartGridSecondary,
    Color? chartBorder,
    Color? actionGradientStart,
    Color? actionGradientEnd,
    Color? success,
    Color? balanced,
    Color? alert,
    List<Color>? analyticsPalette,
  }) {
    return DreamVoyagerPalette(
      cardElevated: cardElevated ?? this.cardElevated,
      navBackground: navBackground ?? this.navBackground,
      chartGrid: chartGrid ?? this.chartGrid,
      chartGridSecondary: chartGridSecondary ?? this.chartGridSecondary,
      chartBorder: chartBorder ?? this.chartBorder,
      actionGradientStart: actionGradientStart ?? this.actionGradientStart,
      actionGradientEnd: actionGradientEnd ?? this.actionGradientEnd,
      success: success ?? this.success,
      balanced: balanced ?? this.balanced,
      alert: alert ?? this.alert,
      analyticsPalette: analyticsPalette ?? this.analyticsPalette,
    );
  }

  @override
  DreamVoyagerPalette lerp(
    covariant ThemeExtension<DreamVoyagerPalette>? other,
    double t,
  ) {
    if (other is! DreamVoyagerPalette) {
      return this;
    }

    return DreamVoyagerPalette(
      cardElevated:
          Color.lerp(cardElevated, other.cardElevated, t) ?? cardElevated,
      navBackground:
          Color.lerp(navBackground, other.navBackground, t) ?? navBackground,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t) ?? chartGrid,
      chartGridSecondary:
          Color.lerp(chartGridSecondary, other.chartGridSecondary, t) ??
          chartGridSecondary,
      chartBorder: Color.lerp(chartBorder, other.chartBorder, t) ?? chartBorder,
      actionGradientStart:
          Color.lerp(actionGradientStart, other.actionGradientStart, t) ??
          actionGradientStart,
      actionGradientEnd:
          Color.lerp(actionGradientEnd, other.actionGradientEnd, t) ??
          actionGradientEnd,
      success: Color.lerp(success, other.success, t) ?? success,
      balanced: Color.lerp(balanced, other.balanced, t) ?? balanced,
      alert: Color.lerp(alert, other.alert, t) ?? alert,
      analyticsPalette: t < 0.5 ? analyticsPalette : other.analyticsPalette,
    );
  }
}

class ThemeService extends ChangeNotifier {
  ThemeService._(this._preferences, this._selectedTheme);

  static const String _preferenceKey = 'dream_voyager_theme';

  static const List<DreamThemeOption> options = <DreamThemeOption>[
    DreamThemeOption(
      theme: DreamAppTheme.midnight,
      label: 'Midnight',
      icon: Icons.bedtime_rounded,
      previewColors: <Color>[
        Color(0xFF0A0E21),
        Color(0xFF16213E),
        Color(0xFF7B61FF),
      ],
    ),
    DreamThemeOption(
      theme: DreamAppTheme.etherealWhite,
      label: 'Ethereal White',
      icon: Icons.wb_sunny_outlined,
      previewColors: <Color>[
        Color(0xFFF7F7FB),
        Color(0xFFE8EBF5),
        Color(0xFF8E6CFF),
      ],
    ),
    DreamThemeOption(
      theme: DreamAppTheme.classicDark,
      label: 'Classic Dark',
      icon: Icons.palette_outlined,
      previewColors: <Color>[
        Color(0xFF121417),
        Color(0xFF2A2F36),
        Color(0xFF76A9FF),
      ],
    ),
  ];

  final SharedPreferences _preferences;
  DreamAppTheme _selectedTheme;

  static Future<ThemeService> create() async {
    final preferences = await SharedPreferences.getInstance();
    final storedTheme = preferences.getString(_preferenceKey);
    return ThemeService._(preferences, _themeFromStorage(storedTheme));
  }

  DreamAppTheme get selectedTheme => _selectedTheme;

  ThemeData get themeData {
    return switch (_selectedTheme) {
      DreamAppTheme.midnight => _buildMidnightTheme(),
      DreamAppTheme.etherealWhite => _buildEtherealWhiteTheme(),
      DreamAppTheme.classicDark => _buildClassicDarkTheme(),
    };
  }

  Future<void> setTheme(DreamAppTheme theme) async {
    if (_selectedTheme == theme) {
      return;
    }

    _selectedTheme = theme;
    notifyListeners();
    await _preferences.setString(_preferenceKey, theme.name);
  }

  static DreamAppTheme _themeFromStorage(String? value) {
    return DreamAppTheme.values
            .where((theme) => theme.name == value)
            .firstOrNull ??
        DreamAppTheme.midnight;
  }

  static ThemeData _buildMidnightTheme() {
    return _buildTheme(
      brightness: Brightness.dark,
      background: const Color(0xFF0A0E21),
      card: const Color(0xFF16213E),
      cardElevated: const Color(0xFF1B2750),
      accent: const Color(0xFF7B61FF),
      accentSecondary: const Color(0xFF9D8AFF),
      navBackground: const Color(0xFF11152D),
      textPrimary: Colors.white,
      textMuted: const Color(0xFFB5BED8),
      textSoft: const Color(0xFF7E89AA),
      outline: const Color(0xFF33416E),
      outlineSoft: const Color(0xFF26335F),
      iconBackground: const Color(0xFF1A1730),
      chartGrid: const Color(0xFF303A69),
      chartGridSecondary: const Color(0xFF28305A),
      chartBorder: const Color(0xFF495184),
      success: const Color(0xFF7BE0A0),
      balanced: const Color(0xFF8FB4FF),
      alert: const Color(0xFFFF8A8A),
      actionGradientStart: const Color(0xFF7F5AF0),
      actionGradientEnd: const Color(0xFFB388FF),
      analyticsPalette: const <Color>[
        Color(0xFF6DA4FF),
        Color(0xFF7E7CFF),
        Color(0xFF965CFF),
        Color(0xFF3E7DD8),
        Color(0xFFB85DCD),
      ],
    );
  }

  static ThemeData _buildEtherealWhiteTheme() {
    return _buildTheme(
      brightness: Brightness.light,
      background: const Color(0xFFF6F7FB),
      card: const Color(0xFFFFFFFF),
      cardElevated: const Color(0xFFEDEFF8),
      accent: const Color(0xFF8E6CFF),
      accentSecondary: const Color(0xFFA88FFF),
      navBackground: const Color(0xFFF0F2F9),
      textPrimary: const Color(0xFF171A29),
      textMuted: const Color(0xFF586079),
      textSoft: const Color(0xFF8088A0),
      outline: const Color(0xFFD6DAE8),
      outlineSoft: const Color(0xFFE3E6F0),
      iconBackground: const Color(0xFFE7E9F4),
      chartGrid: const Color(0xFFD9DDED),
      chartGridSecondary: const Color(0xFFE7EAF4),
      chartBorder: const Color(0xFFCDD3E4),
      success: const Color(0xFF40A56A),
      balanced: const Color(0xFF5B84E6),
      alert: const Color(0xFFD66E76),
      actionGradientStart: const Color(0xFF8E6CFF),
      actionGradientEnd: const Color(0xFFC3B2FF),
      analyticsPalette: const <Color>[
        Color(0xFF8E6CFF),
        Color(0xFF7E9DFF),
        Color(0xFFC58CFF),
        Color(0xFF6F87DB),
        Color(0xFFBC78D8),
      ],
    );
  }

  static ThemeData _buildClassicDarkTheme() {
    return _buildTheme(
      brightness: Brightness.dark,
      background: const Color(0xFF121417),
      card: const Color(0xFF1C1F24),
      cardElevated: const Color(0xFF262B33),
      accent: const Color(0xFF76A9FF),
      accentSecondary: const Color(0xFF9BC0FF),
      navBackground: const Color(0xFF181B20),
      textPrimary: const Color(0xFFF4F7FB),
      textMuted: const Color(0xFFB0B8C4),
      textSoft: const Color(0xFF808894),
      outline: const Color(0xFF3A404A),
      outlineSoft: const Color(0xFF2D333C),
      iconBackground: const Color(0xFF242932),
      chartGrid: const Color(0xFF313844),
      chartGridSecondary: const Color(0xFF2A3038),
      chartBorder: const Color(0xFF495363),
      success: const Color(0xFF73D2A3),
      balanced: const Color(0xFF85B5FF),
      alert: const Color(0xFFFF8E8E),
      actionGradientStart: const Color(0xFF5A94F5),
      actionGradientEnd: const Color(0xFF91B9FF),
      analyticsPalette: const <Color>[
        Color(0xFF76A9FF),
        Color(0xFF8BC2FF),
        Color(0xFF6392E8),
        Color(0xFF99A6B8),
        Color(0xFF4E77C7),
      ],
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color card,
    required Color cardElevated,
    required Color accent,
    required Color accentSecondary,
    required Color navBackground,
    required Color textPrimary,
    required Color textMuted,
    required Color textSoft,
    required Color outline,
    required Color outlineSoft,
    required Color iconBackground,
    required Color chartGrid,
    required Color chartGridSecondary,
    required Color chartBorder,
    required Color success,
    required Color balanced,
    required Color alert,
    required Color actionGradientStart,
    required Color actionGradientEnd,
    required List<Color> analyticsPalette,
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: brightness,
        ).copyWith(
          primary: accent,
          secondary: accentSecondary,
          tertiary: iconBackground,
          surface: card,
          onSurface: textPrimary,
          onSurfaceVariant: textMuted,
          outline: outline,
          outlineVariant: outlineSoft,
          primaryContainer: accent.withValues(
            alpha: brightness == Brightness.dark ? 0.18 : 0.12,
          ),
          onPrimaryContainer: accent,
          secondaryContainer: cardElevated,
          onPrimary: brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF141622),
        );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: card,
      dividerColor: outlineSoft,
      shadowColor: accent.withValues(
        alpha: brightness == Brightness.dark ? 0.24 : 0.14,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: background,
        elevation: 0,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBackground,
        selectedItemColor: textPrimary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: accent.withValues(
          alpha: brightness == Brightness.dark ? 0.2 : 0.08,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardElevated,
        contentTextStyle: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardElevated,
        hintStyle: TextStyle(color: textSoft),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: outlineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
      ),
      textTheme: ThemeData(
        brightness: brightness,
      ).textTheme.apply(bodyColor: textPrimary, displayColor: textPrimary),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
      extensions: <ThemeExtension<dynamic>>[
        DreamVoyagerPalette(
          cardElevated: cardElevated,
          navBackground: navBackground,
          chartGrid: chartGrid,
          chartGridSecondary: chartGridSecondary,
          chartBorder: chartBorder,
          actionGradientStart: actionGradientStart,
          actionGradientEnd: actionGradientEnd,
          success: success,
          balanced: balanced,
          alert: alert,
          analyticsPalette: analyticsPalette,
        ),
      ],
    );

    return baseTheme.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

extension DreamVoyagerThemeContext on BuildContext {
  DreamVoyagerPalette get dreamPalette =>
      Theme.of(this).extension<DreamVoyagerPalette>()!;
}
