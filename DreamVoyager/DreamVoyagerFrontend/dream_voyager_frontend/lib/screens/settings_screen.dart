import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/theme_service.dart';
import '../widgets/dream_bottom_navigation_bar.dart';
import 'analytics_screen.dart';
import 'recorder_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _onNavTap(BuildContext context, int index) async {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (index == 1) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RecorderScreen()),
      );
      return;
    }

    if (index == 2) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text(
                  'Theme',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the visual mood for DreamVoyager.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                for (final option in ThemeService.options) ...[
                  _ThemeCard(
                    option: option,
                    isSelected: themeService.selectedTheme == option.theme,
                    onTap: () => themeService.setTheme(option.theme),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          bottomNavigationBar: DreamBottomNavigationBar(
            currentIndex: 3,
            onTap: (index) => _onNavTap(context, index),
          ),
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final DreamThemeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final borderColor = isSelected
        ? colors.primary
        : colors.outline.withValues(alpha: 0.65);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: isSelected ? 0.22 : 0.08),
              blurRadius: isSelected ? 18 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.tertiary,
              ),
              child: Icon(
                option.icon,
                color: colors.onSurfaceVariant,
                size: 30,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final color in option.previewColors) ...[
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.outline.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isSelected ? 1 : 0,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.34),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Icon(Icons.check_rounded, color: colors.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
