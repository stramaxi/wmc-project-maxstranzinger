import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/theme_service.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = await ThemeService.create();
  runApp(
    ChangeNotifierProvider<ThemeService>.value(
      value: themeService,
      child: const DreamVoyagerApp(),
    ),
  );
}

class DreamVoyagerApp extends StatelessWidget {
  const DreamVoyagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DreamVoyager',
          theme: themeService.themeData,
          home: const DashboardScreen(),
        );
      },
    );
  }
}
