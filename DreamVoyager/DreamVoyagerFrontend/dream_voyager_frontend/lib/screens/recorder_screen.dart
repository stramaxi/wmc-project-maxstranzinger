import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/voice_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/dream_bottom_navigation_bar.dart';
import '../widgets/mood_slider.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class RecordDreamScreen extends StatefulWidget {
  const RecordDreamScreen({super.key});

  @override
  State<RecordDreamScreen> createState() => _RecordDreamScreenState();
}

class _RecordDreamScreenState extends State<RecordDreamScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dreamController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ApiService _apiService = ApiService();
  final VoiceService _voiceService = VoiceService();

  bool _isSaving = false;
  double _moodScore = 5;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool get _isRecording => _voiceService.isListening;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _voiceService.addListener(_handleVoiceStateChanged);
  }

  @override
  void dispose() {
    _voiceService
      ..removeListener(_handleVoiceStateChanged)
      ..dispose();
    _pulseController.dispose();
    _dreamController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _handleVoiceStateChanged() {
    if (!mounted) {
      return;
    }

    if (_voiceService.isListening) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController
        ..stop()
        ..value = 0;
    }

    setState(() {});
  }

  void _showVoiceError(String message) {
    showAppSnackBar(context, message, icon: Icons.mic_off_outlined);
  }

  Future<void> _toggleListening() async {
    await _voiceService.toggleListening(
      controller: _dreamController,
      onError: _showVoiceError,
    );
  }

  Future<void> _startListening() async {
    if (_voiceService.isListening) {
      return;
    }

    await _voiceService.startListening(
      controller: _dreamController,
      onError: _showVoiceError,
    );
  }

  Future<void> _stopListening() async {
    if (!_voiceService.isListening) {
      return;
    }

    await _voiceService.stopListening();
  }

  List<String> _parseTags() {
    return _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> _saveDream() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _apiService.saveDream(
        _dreamController.text.trim(),
        moodScore: _moodScore,
        tags: _parseTags(),
      );
      if (!mounted) {
        return;
      }
      showAppSnackBar(
        context,
        'Dream saved!',
        icon: Icons.check_circle_outline,
        duration: const Duration(seconds: 1),
      );
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, 'Unable to save dream right now.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _onNavTap(int index) async {
    if (index == 0) {
      Navigator.of(context).pop();
      return;
    }

    if (index == 2) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
      );
      return;
    }

    if (index == 3) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Record Dream',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Speak your dream into existence',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: GestureDetector(
                              onTap: _toggleListening,
                              onLongPressStart: (_) => _startListening(),
                              onLongPressEnd: (_) => _stopListening(),
                              child: AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  final pulse = _isRecording
                                      ? _pulseAnimation.value
                                      : 0.0;

                                  return Transform.scale(
                                    scale: 1 + (pulse * 0.04),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      width: 170,
                                      height: 170,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colors.primary.withValues(
                                          alpha: _isRecording
                                              ? 0.32 + (pulse * 0.08)
                                              : 0.18,
                                        ),
                                        border: Border.all(
                                          color: colors.primary.withValues(
                                            alpha: _isRecording ? 0.55 : 0.32,
                                          ),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colors.primary.withValues(
                                              alpha: _isRecording
                                                  ? 0.5 + (pulse * 0.18)
                                                  : 0.3,
                                            ),
                                            blurRadius: _isRecording
                                                ? 34 + (pulse * 18)
                                                : 24,
                                            spreadRadius: _isRecording
                                                ? 3 + (pulse * 6)
                                                : 2,
                                          ),
                                        ],
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Icon(
                                  _isRecording
                                      ? Icons.mic_rounded
                                      : Icons.mic_none_rounded,
                                  size: 58,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              _isRecording
                                  ? 'Recording...'
                                  : 'Tap or hold to start recording',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _dreamController,
                              minLines: 4,
                              maxLines: 6,
                              style: TextStyle(color: colors.onSurface),
                              decoration: InputDecoration(
                                hintText: 'Your words will appear here...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please write your dream before saving.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            MoodSlider(
                              value: _moodScore,
                              onChanged: (value) {
                                setState(() {
                                  _moodScore = value;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _tagsController,
                              onChanged: (_) => setState(() {}),
                              style: TextStyle(color: colors.onSurface),
                              decoration: const InputDecoration(
                                hintText: 'Add tags separated by commas',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                            if (_tagsController.text.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _parseTags()
                                      .map(
                                        (tag) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            color: colors.primary.withValues(
                                              alpha: 0.16,
                                            ),
                                            border: Border.all(
                                              color: colors.primary.withValues(
                                                alpha: 0.35,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            tag,
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: colors.onSurface,
                                                ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _isSaving ? null : _saveDream,
                                style: FilledButton.styleFrom(
                                  disabledBackgroundColor: colors.primary
                                      .withValues(alpha: 0.45),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save Dream'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: DreamBottomNavigationBar(
        currentIndex: 1,
        onTap: _onNavTap,
      ),
    );
  }
}

class RecorderScreen extends StatelessWidget {
  const RecorderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RecordDreamScreen();
  }
}
