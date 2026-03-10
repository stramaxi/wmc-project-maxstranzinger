import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

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

  Widget _navIcon({required IconData icon, required bool isActive}) {
    if (!isActive) {
      return Icon(icon);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF8D5CFF).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D5CFF).withValues(alpha: 0.6),
            blurRadius: 20,
          ),
        ],
      ),
      child: Icon(icon),
    );
  }

  Future<void> _onNavTap(int index) async {
    if (index == 0) {
      Navigator.of(context).pop();
      return;
    }
    if (index == 1) {
      Navigator.of(context).pop();
      return;
    }
    if (index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon.')),
      );
    }
  }

  Widget _buildChartCard(AnalyticsData data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.trend.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.trend[i].moodScore));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2247),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2D3C74)),
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
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFF303A69),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (_) => const FlLine(
                    color: Color(0xFF28305A),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xFF495184), width: 1),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A63FF), Color(0xFF6CA8FF)],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 5,
                        color: const Color(0xFF8D5CFF),
                        strokeWidth: 2,
                        strokeColor: const Color(0xFFB6A0FF),
                      ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.14), height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Avg Mood', value: data.avgMood, color: const Color(0xFF8A63FF)),
              _StatItem(label: 'Best', value: data.bestMood, color: const Color(0xFF8FB4FF)),
              _StatItem(label: 'Lowest', value: data.lowestMood, color: const Color(0xFF77A3FF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCloud(AnalyticsData data) {
    final entries = data.tagFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Text(
        'No themes yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
      );
    }

    final palette = <Color>[
      const Color(0xFF6DA4FF),
      const Color(0xFF7E7CFF),
      const Color(0xFF965CFF),
      const Color(0xFF3E7DD8),
      const Color(0xFFB85DCD),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (int i = 0; i < entries.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: palette[i % palette.length].withValues(alpha: 0.18),
              border: Border.all(
                color: palette[i % palette.length].withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: palette[i % palette.length].withValues(alpha: 0.22),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Text(
              entries[i].key,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
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
              final isNetworkError = error is SocketException ||
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(onPressed: _retry, child: const Text('Retry')),
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
                          color: const Color(0xFF8D5CFF).withValues(alpha: 0.28),
                        ),
                        child: const Icon(Icons.trending_up_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analytics',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            'Your dream insights',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white60,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Mood Trends',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 14),
                  _buildChartCard(data),
                  const SizedBox(height: 26),
                  Text(
                    'Dream Themes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2247),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF2D3C74)),
                    ),
                    child: _buildThemeCloud(data),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: _onNavTap,
        backgroundColor: const Color(0xFF11152D),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: _navIcon(icon: Icons.cloud_outlined, isActive: false),
            activeIcon: _navIcon(icon: Icons.cloud_outlined, isActive: true),
            label: 'Dreams',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(icon: Icons.mic_none_rounded, isActive: false),
            activeIcon: _navIcon(icon: Icons.mic_none_rounded, isActive: true),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(icon: Icons.bar_chart_outlined, isActive: false),
            activeIcon: _navIcon(icon: Icons.bar_chart_outlined, isActive: true),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(icon: Icons.settings_outlined, isActive: false),
            activeIcon: _navIcon(icon: Icons.settings_outlined, isActive: true),
            label: 'Settings',
          ),
        ],
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white60),
        ),
      ],
    );
  }
}
