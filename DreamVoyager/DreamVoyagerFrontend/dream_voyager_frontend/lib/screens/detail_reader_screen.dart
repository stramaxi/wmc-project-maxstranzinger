import 'package:flutter/material.dart';
import 'dart:io';

import '../models/dream_model.dart';
import '../services/api_service.dart';
import '../services/theme_service.dart';
import '../services/voice_service.dart';
import '../widgets/app_snackbar.dart';

class DetailReaderScreen extends StatefulWidget {
  const DetailReaderScreen({this.dream, this.dreamId, super.key})
    : assert(dream != null || dreamId != null);

  final Dream? dream;
  final String? dreamId;

  @override
  State<DetailReaderScreen> createState() => _DetailReaderScreenState();
}

class _DetailReaderScreenState extends State<DetailReaderScreen> {
  final ApiService _apiService = ApiService();
  final VoiceService _voiceService = VoiceService();
  late Future<Dream> _dreamFuture;

  @override
  void initState() {
    super.initState();
    _dreamFuture = widget.dream != null
        ? Future<Dream>.value(widget.dream!)
        : _apiService.fetchDreamById(widget.dreamId!);
    _voiceService.addListener(_handleVoiceStateChanged);
  }

  @override
  void dispose() {
    _voiceService
      ..removeListener(_handleVoiceStateChanged)
      ..dispose();
    super.dispose();
  }

  void _handleVoiceStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleDreamPlayback(String content) async {
    try {
      await _voiceService.toggleSpeaking(content);
    } on VoiceServiceException catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, error.message, icon: Icons.volume_off_rounded);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(
        context,
        'Audio playback is unavailable right now.',
        icon: Icons.volume_off_rounded,
      );
    }
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
    final palette = context.dreamPalette;

    if (score >= 8) {
      return palette.success;
    }
    if (score >= 5) {
      return palette.balanced;
    }
    return palette.alert;
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final normalized = score.clamp(0, 10).toDouble() / 10;
    final color = _moodColor(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
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
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurfaceVariant,
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
        _topIconButton(icon: Icons.bookmark_border_rounded, onTap: () {}),
        const SizedBox(width: 10),
        _topIconButton(icon: Icons.share_outlined, onTap: () {}),
      ],
    );
  }

  Widget _topIconButton({required IconData icon, required VoidCallback onTap}) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: colors.surface,
          border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: colors.onSurface),
      ),
    );
  }

  Widget _buildDreamThemes(List<String> tags) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (tags.isEmpty) {
      return Text(
        'No dream themes yet.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
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
                color: colors.primary.withValues(alpha: 0.16),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.34),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.2),
                    blurRadius: 14,
                    spreadRadius: 0.4,
                  ),
                ],
              ),
              child: Text(
                tag,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLoadedView(Dream dream) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final palette = context.dreamPalette;

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
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
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
                gradient: LinearGradient(
                  colors: <Color>[
                    palette.actionGradientStart,
                    palette.actionGradientEnd,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _toggleDreamPlayback(dream.content),
                icon: Icon(
                  _voiceService.isSpeaking
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  size: 24,
                ),
                label: Text(
                  _voiceService.isSpeaking ? 'Stop Reading' : 'Listen to Dream',
                ),
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
                  color: colors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor,
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
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface,
                        fontSize: 17,
                        height: 1.65,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Divider(
                      color: theme.dividerColor.withValues(alpha: 0.8),
                      height: 1,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Dream Themes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
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
