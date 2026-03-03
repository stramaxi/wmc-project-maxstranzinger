import 'package:flutter/material.dart';

import '../models/dream_model.dart';

class DetailReaderScreen extends StatelessWidget {
  const DetailReaderScreen({
    required this.dream,
    super.key,
  });

  final Dream dream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Hero(
          tag: 'dream-${dream.id}',
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dream.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        dream.content,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(height: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}