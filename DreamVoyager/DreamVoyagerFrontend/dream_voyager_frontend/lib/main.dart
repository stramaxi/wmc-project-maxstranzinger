import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';

void main() {
  runApp(const DreamVoyagerApp());
}

class DreamVoyagerApp extends StatelessWidget {
  const DreamVoyagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF1A1A2E);
    const primary = Color(0xFF16213E);
    const accent = Color(0xFF0F3460);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DreamVoyager',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ).copyWith(
          primary: primary,
          secondary: accent,
          surface: primary,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF16213E),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: accent.withValues(alpha: 0.32),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: primary.withValues(alpha: 0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: accent, width: 1.4),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
