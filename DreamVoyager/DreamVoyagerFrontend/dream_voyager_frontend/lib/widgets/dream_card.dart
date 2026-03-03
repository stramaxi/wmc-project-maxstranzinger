import 'package:flutter/material.dart';

import '../models/dream_model.dart';

class DreamCard extends StatelessWidget {
  const DreamCard({
    required this.dream,
    required this.onTap,
    super.key,
  });

  final Dream dream;
  final VoidCallback onTap;

  String _moodEmoji(double score) {
    if (score >= 8) {
      return '😌';
    }
    if (score >= 4) {
      return '🧐';
    }
    return '😨';
  }

  String _formattedDate(DateTime? dateTime) {
    final date = dateTime ?? DateTime.now();
    final month = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][date.month - 1];
    return '${date.day.toString().padLeft(2, '0')} $month ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = dream.tags;

    return Hero(
      tag: 'dream-${dream.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF2A2340),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8D5CFF).withValues(alpha: 0.16),
                  blurRadius: 20,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formattedDate(dream.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _moodEmoji(dream.moodScore),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  dream.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 12),
                if (tags.isEmpty)
                  Text(
                    'No tags',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
                  )
                else
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tags.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8D5CFF).withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color:
                                  const Color(0xFFB49BFF).withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(
                            tags[index],
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}