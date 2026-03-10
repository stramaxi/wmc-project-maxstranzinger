import 'package:flutter/material.dart';
import 'dart:io';

import '../models/dream_model.dart';
import '../services/api_service.dart';

class DetailReaderScreen extends StatefulWidget {
  const DetailReaderScreen({
    this.dream,
    this.dreamId,
    super.key,
  }) : assert(dream != null || dreamId != null);

  final Dream? dream;
  final String? dreamId;

  @override
  State<DetailReaderScreen> createState() => _DetailReaderScreenState();
}

class _DetailReaderScreenState extends State<DetailReaderScreen> {
  final ApiService _apiService = ApiService();
  late Future<Dream> _dreamFuture;

  @override
  void initState() {
    super.initState();
    _dreamFuture = widget.dream != null
        ? Future<Dream>.value(widget.dream!)
        : _apiService.fetchDreamById(widget.dreamId!);
  }

  String _moodEmoji(double score) {
    if (score >= 8) {
      return '😌';
    }
    if (score >= 4) {
      return '🧐';
    }
    return '😨';
  }

  Color _moodColor(double score) {
    if (score >= 8) {
      return const Color(0xFF7BE0A0);
    }
    if (score >= 5) {
      return const Color(0xFF8FB4FF);
    }
    return const Color(0xFFFF8A8A);
  }

  String _moodLabel(double score) {
    if (score >= 8) {
      return 'Excellent Vibe';
    }
    if (score >= 5) {
      return 'Balanced Mood';
    }
    return 'Stormy Mood';
  }

  Widget _buildMoodRing(double score) {
    final normalized = (score.clamp(0, 10) as num).toDouble() / 10;
    final color = _moodColor(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: normalized,
                  strokeWidth: 7,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Text(
                  score.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mood Score',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _moodLabel(score),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formattedFullDate(DateTime? dateTime) {
    final date = dateTime ?? DateTime.now();
    const weekdays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _topIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        const Spacer(),
        _topIconButton(
          icon: Icons.bookmark_border_rounded,
          onTap: () {},
        ),
        const SizedBox(width: 10),
        _topIconButton(
          icon: Icons.share_outlined,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _topIconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF16213E),
          border: Border.all(color: const Color(0xFF8D5CFF).withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildDreamThemes(List<String> tags) {
    if (tags.isEmpty) {
      return Text(
        'No dream themes yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white60,
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: const Color(0xFF8D5CFF).withValues(alpha: 0.19),
                border: Border.all(
                  color: const Color(0xFFC8B4FF).withValues(alpha: 0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8D5CFF).withValues(alpha: 0.28),
                    blurRadius: 14,
                    spreadRadius: 0.4,
                  ),
                ],
              ),
              child: Text(
                tag,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLoadedView(Dream dream) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(),
          const SizedBox(height: 22),
          Row(
            children: [
              Text(
                _moodEmoji(dream.moodScore),
                style: const TextStyle(fontSize: 34),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formattedFullDate(dream.createdAt),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildMoodRing(dream.moodScore),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7F5AF0), Color(0xFFB388FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8D5CFF).withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: const Text('Listen to Dream'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Hero(
            tag: 'dream-${dream.id}',
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFF16213E),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dream.content,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFFE7EBFF),
                            fontSize: 17,
                            height: 1.65,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: 18),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.18),
                      height: 1,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Dream Themes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _buildDreamThemes(dream.tags),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: FutureBuilder<Dream>(
            future: _dreamFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                final error = snapshot.error;
                final String message = error is SocketException
                    ? 'Could not connect to the backend. Check if it is running at 10.0.2.2:3000.'
                    : 'Could not load dream details.\n$error';

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ),
                );
              }

              final dream = snapshot.data;
              if (dream == null) {
                return Center(
                  child: Text(
                    'Dream not found.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                );
              }

              return _buildLoadedView(dream);
            },
          ),
        ),
      ),
    );
  }
}