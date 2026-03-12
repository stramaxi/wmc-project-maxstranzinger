import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService extends ChangeNotifier {
  VoiceService({FlutterTts? flutterTts, stt.SpeechToText? speechToText})
    : _flutterTts = flutterTts ?? FlutterTts(),
      _speechToText = speechToText ?? stt.SpeechToText() {
    _flutterTts.setStartHandler(() {
      _setSpeaking(true);
    });
    _flutterTts.setCompletionHandler(() {
      _setSpeaking(false);
    });
    _flutterTts.setCancelHandler(() {
      _setSpeaking(false);
    });
    _flutterTts.setErrorHandler((_) {
      _setSpeaking(false);
    });
  }

  final FlutterTts _flutterTts;
  final stt.SpeechToText _speechToText;

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechInitialized = false;
  bool _disposed = false;
  bool _manualStopRequested = false;
  bool _receivedAnySpeechResult = false;
  String _speechSeedText = '';
  TextEditingController? _activeController;
  ValueChanged<String>? _onSpeechError;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  Future<void> toggleSpeaking(String text) async {
    if (_isSpeaking) {
      await stopSpeaking();
      return;
    }

    await speak(text);
  }

  Future<void> speak(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw const VoiceServiceException('Nothing to read aloud yet.');
    }

    await stopListening();

    final language = _resolveTtsLanguage(trimmedText);

    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(0.42);
    await _flutterTts.setPitch(0.78);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.speak(trimmedText);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _setSpeaking(false);
  }

  Future<void> toggleListening({
    required TextEditingController controller,
    required ValueChanged<String> onError,
  }) async {
    if (_isListening) {
      await stopListening();
      return;
    }

    await startListening(controller: controller, onError: onError);
  }

  Future<bool> startListening({
    required TextEditingController controller,
    required ValueChanged<String> onError,
  }) async {
    if (!_supportsSpeechToText()) {
      onError('Speech-to-Text ist aktuell nur auf Android und iOS verfuegbar.');
      return false;
    }

    await stopSpeaking();
    _onSpeechError = onError;

    final available = await _ensureSpeechInitialized();
    if (!available) {
      onError('Microphone permission was denied.');
      return false;
    }

    _activeController = controller;
    _manualStopRequested = false;
    _receivedAnySpeechResult = false;
    _speechSeedText = controller.text.trimRight();

    try {
      final localeId = await _resolveSpeechLocaleId();

      await _speechToText.listen(
        onResult: _handleSpeechResult,
        pauseFor: const Duration(seconds: 8),
        listenFor: const Duration(minutes: 2),
        localeId: localeId,
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
          cancelOnError: true,
        ),
      );

      _setListening(true);
      return true;
    } catch (_) {
      _setListening(false);
      onError('Microphone unavailable right now.');
      return false;
    }
  }

  Future<void> stopListening() async {
    _manualStopRequested = true;
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    _setListening(false);
  }

  Future<void> cancelListening() async {
    _manualStopRequested = true;
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
    _setListening(false);
  }

  bool _supportsSpeechToText() {
    if (kIsWeb) {
      return false;
    }

    return Platform.isAndroid || Platform.isIOS;
  }

  Future<bool> _ensureSpeechInitialized() async {
    if (_speechInitialized) {
      return true;
    }

    _speechInitialized = await _speechToText.initialize(
      debugLogging: false,
      onError: _handleSpeechError,
      onStatus: _handleSpeechStatus,
    );
    return _speechInitialized;
  }

  Future<String?> _resolveSpeechLocaleId() async {
    final systemLocale = await _speechToText.systemLocale();
    if (systemLocale != null && systemLocale.localeId.isNotEmpty) {
      return systemLocale.localeId;
    }

    final locales = await _speechToText.locales();

    for (final locale in locales) {
      final normalized = locale.localeId.toLowerCase().replaceAll('_', '-');
      if (normalized.startsWith('de-')) {
        return locale.localeId;
      }
    }

    for (final locale in locales) {
      final normalized = locale.localeId.toLowerCase().replaceAll('_', '-');
      if (normalized.startsWith('en-')) {
        return locale.localeId;
      }
    }

    return null;
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    final controller = _activeController;
    if (controller == null) {
      return;
    }

    if (result.recognizedWords.trim().isNotEmpty) {
      _receivedAnySpeechResult = true;
    }

    final recognizedWords = result.recognizedWords.trim();
    final composedText = _composeText(_speechSeedText, recognizedWords);

    controller.value = controller.value.copyWith(
      text: composedText,
      selection: TextSelection.collapsed(offset: composedText.length),
      composing: TextRange.empty,
    );

    if (result.finalResult) {
      _speechSeedText = composedText;
      _setListening(false);
    }
  }

  void _handleSpeechStatus(String status) {
    if (status == 'notListening' || status == 'done') {
      _setListening(false);
      _manualStopRequested = false;
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    _setListening(false);

    if (error.errorMsg == 'error_speech_timeout' && _receivedAnySpeechResult) {
      _manualStopRequested = false;
      return;
    }

    if (_shouldIgnoreSpeechError(error.errorMsg)) {
      _manualStopRequested = false;
      return;
    }

    final message = switch (error.errorMsg) {
      'error_permission' ||
      'error_permission_denied' => 'Microphone permission was denied.',
      'error_no_match' => 'No speech detected. Try again.',
      'error_speech_timeout' =>
        'Listening timed out. Speak right after tapping the microphone.',
      _ => 'Voice capture stopped unexpectedly.',
    };

    _onSpeechError?.call(message);
  }

  bool _shouldIgnoreSpeechError(String errorCode) {
    if (_manualStopRequested) {
      return true;
    }

    // These error callbacks are commonly emitted after normal end-of-listen.
    if (errorCode == 'error_no_match' && _receivedAnySpeechResult) {
      return true;
    }

    return errorCode == 'error_client' ||
        errorCode == 'error_server_disconnected';
  }

  String _composeText(String seedText, String recognizedWords) {
    if (recognizedWords.isEmpty) {
      return seedText;
    }
    if (seedText.isEmpty) {
      return recognizedWords;
    }
    return '$seedText $recognizedWords';
  }

  String _resolveTtsLanguage(String text) {
    final lower = text.toLowerCase();
    const germanMarkers = <String>[
      ' und ',
      ' ich ',
      ' nicht ',
      ' der ',
      ' die ',
      ' das ',
      ' ein ',
      ' eine ',
      ' ist ',
      ' mit ',
      ' traum',
      'ä',
      'ö',
      'ü',
      'ß',
    ];

    for (final marker in germanMarkers) {
      if (lower.contains(marker)) {
        return 'de-DE';
      }
    }

    return 'en-US';
  }

  void _setListening(bool value) {
    if (_isListening == value) {
      return;
    }
    _isListening = value;
    _notify();
  }

  void _setSpeaking(bool value) {
    if (_isSpeaking == value) {
      return;
    }
    _isSpeaking = value;
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
}

class VoiceServiceException implements Exception {
  const VoiceServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
