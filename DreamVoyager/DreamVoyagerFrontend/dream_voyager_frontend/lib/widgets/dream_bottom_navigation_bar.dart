import 'package:flutter/material.dart';

class DreamBottomNavigationBar extends StatelessWidget {
  const DreamBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  Widget _navIcon(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedColor =
        theme.bottomNavigationBarTheme.selectedItemColor ?? colors.onSurface;

    if (!isActive) {
      return Icon(icon);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.32),
            blurRadius: 18,
            spreadRadius: 0.4,
          ),
        ],
      ),
      child: Icon(icon, color: selectedColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: _navIcon(context, icon: Icons.cloud_outlined, isActive: false),
          activeIcon: _navIcon(
            context,
            icon: Icons.cloud_outlined,
            isActive: true,
          ),
          label: 'Dreams',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(
            context,
            icon: Icons.mic_none_rounded,
            isActive: false,
          ),
          activeIcon: _navIcon(
            context,
            icon: Icons.mic_none_rounded,
            isActive: true,
          ),
          label: 'Record',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(
            context,
            icon: Icons.bar_chart_outlined,
            isActive: false,
          ),
          activeIcon: _navIcon(
            context,
            icon: Icons.bar_chart_outlined,
            isActive: true,
          ),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(
            context,
            icon: Icons.settings_outlined,
            isActive: false,
          ),
          activeIcon: _navIcon(
            context,
            icon: Icons.settings_outlined,
            isActive: true,
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}
