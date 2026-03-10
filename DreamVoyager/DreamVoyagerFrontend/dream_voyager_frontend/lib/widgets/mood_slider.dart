import 'package:flutter/material.dart';

class MoodSlider extends StatelessWidget {
  const MoodSlider({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;

  Color _colorForValue(double mood) {
    final t = ((mood - 1) / 9).clamp(0.0, 1.0);
    return Color.lerp(const Color(0xFF3C67FF), const Color(0xFFF1C96A), t) ?? const Color(0xFF8D5CFF);
  }

  @override
  Widget build(BuildContext context) {
    final glow = _colorForValue(value);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111B3B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glow.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.22),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Mood',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: glow,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: glow,
              inactiveTrackColor: const Color(0xFF3A4270),
              thumbColor: glow,
              overlayColor: glow.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 10,
              divisions: 18,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
              Text('10', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }
}
