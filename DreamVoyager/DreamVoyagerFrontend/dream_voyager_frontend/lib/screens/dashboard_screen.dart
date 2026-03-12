import 'package:flutter/material.dart';

import '../models/dream_model.dart';
import '../services/api_service.dart';
import '../widgets/dream_bottom_navigation_bar.dart';
import '../widgets/dream_card.dart';
import 'analytics_screen.dart';
import 'detail_reader_screen.dart';
import 'recorder_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Dream>> _dreamsFuture;

  @override
  void initState() {
    super.initState();
    _dreamsFuture = _apiService.fetchDreams();
  }

  Future<void> _refreshDreams() async {
    setState(() {
      _dreamsFuture = _apiService.fetchDreams();
    });
    await _dreamsFuture;
  }

  Future<void> _openRecorder() async {
    final bool? saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const RecorderScreen()));

    if (saved == true && mounted) {
      await _refreshDreams();
    }
  }

  Future<void> _openAnalytics() async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  void _openDetail(Dream dream) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DetailReaderScreen(dream: dream)));
  }

  Future<void> _onNavTap(int index) async {
    if (index == 1) {
      await _openRecorder();
      return;
    }

    if (index == 2) {
      await _openAnalytics();
      return;
    }

    if (index == 3) {
      await _openSettings();
    }
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DreamVoyager',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your mystical journey',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.tertiary,
            border: Border.all(color: colors.primary.withValues(alpha: 0.55)),
          ),
          child: Icon(Icons.cloud_outlined, color: colors.onSurface),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(int count) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dream Cloud',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '$count dreams captured',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDreamsList(List<Dream> dreams) {
    if (dreams.isEmpty) {
      return const Center(child: Text('No dreams yet. Record your first one.'));
    }

    return RefreshIndicator(
      onRefresh: _refreshDreams,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: dreams.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final dream = dreams[index];
          return DreamCard(dream: dream, onTap: () => _openDetail(dream));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<Dream>>(
                  future: _dreamsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Could not load dreams.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final dreams = snapshot.data ?? <Dream>[];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(dreams.length),
                        const SizedBox(height: 12),
                        Expanded(child: _buildDreamsList(dreams)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DreamBottomNavigationBar(
        currentIndex: 0,
        onTap: _onNavTap,
      ),
    );
  }
}
