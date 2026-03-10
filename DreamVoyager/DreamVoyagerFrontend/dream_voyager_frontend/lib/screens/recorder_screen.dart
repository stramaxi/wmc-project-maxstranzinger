import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/mood_slider.dart';

class RecordDreamScreen extends StatefulWidget {
  const RecordDreamScreen({super.key});

  @override
  State<RecordDreamScreen> createState() => _RecordDreamScreenState();
}

class _RecordDreamScreenState extends State<RecordDreamScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dreamController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isSaving = false;
  bool _isRecording = false;
  double _moodScore = 5;

  @override
  void dispose() {
    _dreamController.dispose();
    _tagsController.dispose();
    super.dispose();
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Dream saved!'),
              ],
            ),
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save dream right now.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _navIcon({required IconData icon, required bool isActive}) {
    if (!isActive) {
      return Icon(icon);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF8D5CFF).withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D5CFF).withValues(alpha: 0.55),
            blurRadius: 18,
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

    if (index == 2 || index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
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
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Speak your dream into existence',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white60,
                                ),
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isRecording = !_isRecording;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF7B61FF).withValues(
                                    alpha: _isRecording ? 0.32 : 0.18,
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF7B61FF).withValues(
                                      alpha: _isRecording ? 0.55 : 0.32,
                                    ),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7B61FF).withValues(
                                        alpha: _isRecording ? 0.68 : 0.3,
                                      ),
                                      blurRadius: _isRecording ? 46 : 24,
                                      spreadRadius: _isRecording ? 7 : 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.mic_none_rounded,
                                  size: 58,
                                  color: Color(0xFF9F8BFF),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              _isRecording ? 'Recording...' : 'Tap to start recording',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white60,
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
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2F3F73),
                          ),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _dreamController,
                              minLines: 4,
                              maxLines: 6,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Your words will appear here...',
                                hintStyle: TextStyle(color: Colors.white38),
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
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Add tags separated by commas',
                                hintStyle: TextStyle(color: Colors.white38),
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
                                            borderRadius: BorderRadius.circular(999),
                                            color: const Color(0xFF8D5CFF)
                                                .withValues(alpha: 0.2),
                                            border: Border.all(
                                              color: const Color(0xFFC8B4FF)
                                                  .withValues(alpha: 0.45),
                                            ),
                                          ),
                                          child: Text(
                                            tag,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(color: Colors.white),
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
                                  backgroundColor: const Color(0xFF7B61FF),
                                  disabledBackgroundColor:
                                      const Color(0xFF7B61FF).withValues(alpha: 0.45),
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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

class RecorderScreen extends StatelessWidget {
  const RecorderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RecordDreamScreen();
  }
}