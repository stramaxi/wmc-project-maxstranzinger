import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/theme_service.dart';
import '../widgets/dream_bottom_navigation_bar.dart';
import 'recorder_screen.dart';
import 'settings_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ApiService _apiService = ApiService();
  late Future<AnalyticsData> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _apiService.getAnalytics();
  }

  Future<void> _retry() async {
    setState(() {
      _analyticsFuture = _apiService.getAnalytics();
    });
  }

  Future<void> _onNavTap(int index) async {
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

    if (index == 3) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }

  Widget _buildChartCard(AnalyticsData data) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final palette = context.dreamPalette;
    final spots = <FlSpot>[];
    for (int i = 0; i < data.trend.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.trend[i].moodScore));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.cardElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 2,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: palette.chartGrid, strokeWidth: 1),
                  getDrawingVerticalLine: (_) =>
                      FlLine(color: palette.chartGridSecondary, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.trend.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data.trend[index].label,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: palette.chartBorder, width: 1),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: <Color>[colors.primary, colors.secondary],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: colors.primary,
                            strokeWidth: 2,
                            strokeColor: colors.secondary,
                          ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor.withValues(alpha: 0.7), height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Avg Mood',
                value: data.avgMood,
                color: colors.primary,
              ),
              _StatItem(
                label: 'Best',
                value: data.bestMood,
                color: palette.balanced,
              ),
              _StatItem(
                label: 'Lowest',
                value: data.lowestMood,
                color: palette.alert,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCloud(AnalyticsData data) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final palette = context.dreamPalette;
    final entries = data.tagFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Text(
        'No themes yet.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (int i = 0; i < entries.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: palette
                  .analyticsPalette[i % palette.analyticsPalette.length]
                  .withValues(alpha: 0.18),
              border: Border.all(
                color: palette
                    .analyticsPalette[i % palette.analyticsPalette.length]
                    .withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: palette
                      .analyticsPalette[i % palette.analyticsPalette.length]
                      .withValues(alpha: 0.22),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Text(
              entries[i].key,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final palette = context.dreamPalette;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: FutureBuilder<AnalyticsData>(
          future: _analyticsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final error = snapshot.error;
              final errorText = error.toString().toLowerCase();
              final isNetworkError =
                  error is SocketException ||
                  errorText.contains('network error') ||
                  errorText.contains('socketexception');
              final message = isNetworkError
                  ? 'Server not reached. Check localhost:3000 and retry.'
                  : 'Could not load analytics.\n$error';

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: _retry,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.withValues(alpha: 0.16),
                        ),
                        child: Icon(
                          Icons.trending_up_rounded,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analytics',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Your dream insights',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Mood Trends',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildChartCard(data),
                  const SizedBox(height: 26),
                  Text(
                    'Dream Themes',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: palette.cardElevated,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: colors.outline),
                    ),
                    child: _buildThemeCloud(data),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: DreamBottomNavigationBar(
        currentIndex: 2,
        onTap: _onNavTap,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.45), blurRadius: 12),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
