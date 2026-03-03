import 'package:flutter/material.dart';

import '../models/dream_model.dart';
import '../services/api_service.dart';
import '../widgets/dream_card.dart';
import 'detail_reader_screen.dart';
import 'recorder_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Dream>> _dreamsFuture;
  int _selectedTab = 0;

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
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const RecorderScreen(),
      ),
    );

    if (saved == true && mounted) {
      await _refreshDreams();
    }
  }

  void _openDetail(Dream dream) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailReaderScreen(dream: dream),
      ),
    );
  }

  Widget _navIcon({
    required IconData icon,
    required bool isActive,
  }) {
    if (!isActive) {
      return Icon(icon);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF8D5CFF).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D5CFF).withValues(alpha: 0.55),
            blurRadius: 16,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Icon(icon),
    );
  }

  Future<void> _onNavTap(int index) async {
    if (index == 1) {
      await _openRecorder();
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedTab = 0;
      });
      return;
    }

    if (index == 2 || index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon.')),
      );
      setState(() {
        _selectedTab = index;
      });
      return;
    }

    setState(() {
      _selectedTab = index;
    });
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DreamVoyager',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your mystical journey',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade400,
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
            color: const Color(0xFF1A1730),
            border: Border.all(color: const Color(0xFF8D5CFF).withValues(alpha: 0.55)),
          ),
          child: const Icon(Icons.cloud_outlined, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dream Cloud',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        Text(
          '$count dreams captured',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade400,
              ),
        ),
      ],
    );
  }

  Widget _buildDreamsList(List<Dream> dreams) {
    if (dreams.isEmpty) {
      return const Center(
        child: Text('No dreams yet. Record your first one.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshDreams,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: dreams.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final dream = dreams[index];
          return DreamCard(
            dream: dream,
            onTap: () => _openDetail(dream),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
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
            activeIcon:
                _navIcon(icon: Icons.mic_none_rounded, isActive: true),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(icon: Icons.bar_chart_outlined, isActive: false),
            activeIcon:
                _navIcon(icon: Icons.bar_chart_outlined, isActive: true),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(icon: Icons.settings_outlined, isActive: false),
            activeIcon:
                _navIcon(icon: Icons.settings_outlined, isActive: true),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}