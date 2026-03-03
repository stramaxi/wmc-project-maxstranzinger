import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dreamController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isSaving = false;

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }

  Future<void> _saveDream() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _apiService.saveDream(_dreamController.text);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Dream')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _dreamController,
                minLines: 8,
                maxLines: 12,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Describe your dream journey...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please write your dream before saving.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              Align(
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.45),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.35),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {},
                    iconSize: 52,
                    icon: const Icon(Icons.mic, color: Colors.white),
                    tooltip: 'Speech-to-Text (coming soon)',
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: _isSaving ? null : _saveDream,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Dream'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}