import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/dream_model.dart';

class MoodTrendPoint {
  MoodTrendPoint({
    required this.label,
    required this.moodScore,
  });

  final String label;
  final double moodScore;
}

class AnalyticsData {
  AnalyticsData({
    required this.avgMood,
    required this.bestMood,
    required this.lowestMood,
    required this.trend,
    required this.tagFrequency,
  });

  final double avgMood;
  final double bestMood;
  final double lowestMood;
  final List<MoodTrendPoint> trend;
  final Map<String, int> tagFrequency;
}

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _androidEmulatorBaseUrl = 'http://localhost:3000/api';
  static const Duration _requestTimeout = Duration(seconds: 12);

  Future<http.Response> _getWithRetry(Uri url, {int retries = 1}) async {
    int attempts = 0;

    while (true) {
      try {
        attempts += 1;
        return await http.get(url).timeout(_requestTimeout);
      } on SocketException {
        if (attempts > retries) {
          rethrow;
        }
        await Future<void>.delayed(const Duration(milliseconds: 450));
      }
    }
  }

  List<Dream> _parseDreamList(dynamic decoded) {
    final List<dynamic> list = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> && decoded['data'] is List
            ? decoded['data'] as List<dynamic>
            : <dynamic>[]);

    return list
        .map((item) => Dream.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String _shortDateLabel(DateTime date) {
    return '${date.month}/${date.day}';
  }

  Future<List<Dream>> fetchDreams() async {
    final Uri url = Uri.parse('$_baseUrl/dreams');

    try {
      final response = await _getWithRetry(url);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load dreams (HTTP ${response.statusCode}).',
        );
      }

        final dynamic decoded = jsonDecode(response.body);
        return _parseDreamList(decoded);
    } on SocketException catch (e) {
      throw Exception(
        'Network error while loading dreams. Check backend host/port and Android emulator networking. ($e)',
      );
    } on TimeoutException {
      throw Exception(
        'Request to load dreams timed out. Verify backend is running on port 3000 and reachable from emulator.',
      );
    } on FormatException catch (e) {
      throw Exception('Invalid dreams JSON format from server. ($e)');
    } catch (e) {
      throw Exception('Unexpected error while loading dreams: $e');
    }
  }

  Future<AnalyticsData> getAnalytics() async {
    final dreams = await fetchDreams();

    if (dreams.isEmpty) {
      return AnalyticsData(
        avgMood: 0,
        bestMood: 0,
        lowestMood: 0,
        trend: const <MoodTrendPoint>[],
        tagFrequency: const <String, int>{},
      );
    }

    final sorted = [...dreams]
      ..sort(
        (a, b) => (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
      );

    final visible = sorted.length > 6
        ? sorted.sublist(sorted.length - 6)
        : sorted;

    final trend = visible
        .map(
          (dream) => MoodTrendPoint(
            label: _shortDateLabel(dream.createdAt ?? DateTime.now()),
            moodScore: dream.moodScore.clamp(0, 10).toDouble(),
          ),
        )
        .toList();

    final allScores = dreams.map((dream) => dream.moodScore.clamp(0, 10).toDouble()).toList();
    final avgMood = allScores.reduce((a, b) => a + b) / allScores.length;
    final bestMood = allScores.reduce((a, b) => a > b ? a : b);
    final lowestMood = allScores.reduce((a, b) => a < b ? a : b);

    final Map<String, int> tagFrequency = <String, int>{};
    for (final dream in dreams) {
      for (final tag in dream.tags) {
        final normalized = tag.trim();
        if (normalized.isEmpty) {
          continue;
        }
        tagFrequency.update(normalized, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    return AnalyticsData(
      avgMood: avgMood,
      bestMood: bestMood,
      lowestMood: lowestMood,
      trend: trend,
      tagFrequency: tagFrequency,
    );
  }

  Future<Dream> saveDream(
    String content, {
    double moodScore = 5,
    int isLucid = 0,
    List<String> tags = const <String>[],
  }) async {
    final Uri url = Uri.parse('$_androidEmulatorBaseUrl/dreams');
    debugPrint('[ApiService] POST $url');

    final body = jsonEncode(<String, dynamic>{
      'content': content,
      'mood_score': moodScore,
      'is_lucid': isLucid,
      'tags': tags,
    });

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_requestTimeout);
      debugPrint('[ApiService] POST $url -> ${response.statusCode}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to save dream (HTTP ${response.statusCode}).',
        );
      }

      final dynamic decoded = jsonDecode(response.body);
      final Map<String, dynamic> json =
          decoded is Map<String, dynamic> && decoded['dream'] is Map<String, dynamic>
              ? decoded['dream'] as Map<String, dynamic>
              : decoded as Map<String, dynamic>;

      return Dream.fromJson(json);
    } on SocketException catch (e) {
      throw Exception(
        'Network error while saving dream. Check backend connectivity and cleartext settings. ($e)',
      );
    } on TimeoutException {
      throw Exception(
        'Request to save dream timed out. Verify backend responsiveness and emulator network route.',
      );
    } on FormatException catch (e) {
      throw Exception('Invalid save response JSON format from server. ($e)');
    } catch (e) {
      throw Exception('Unexpected error while saving dream: $e');
    }
  }

  Future<Dream> fetchDreamById(String id) async {
    final Uri url = Uri.parse('$_androidEmulatorBaseUrl/dreams/$id');

    try {
      final response = await http.get(url).timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load dream (HTTP ${response.statusCode}).',
        );
      }

      final dynamic decoded = jsonDecode(response.body);
      final Map<String, dynamic> json =
          decoded is Map<String, dynamic> && decoded['dream'] is Map<String, dynamic>
              ? decoded['dream'] as Map<String, dynamic>
              : (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>
                  ? decoded['data'] as Map<String, dynamic>
                  : decoded as Map<String, dynamic>);

      return Dream.fromJson(json);
    } on SocketException {
      rethrow;
    } on TimeoutException {
      throw Exception(
        'Request to load dream timed out. Verify backend is reachable at localhost:3000.',
      );
    } on FormatException catch (e) {
      throw Exception('Invalid dream JSON format from server. ($e)');
    } catch (e) {
      throw Exception('Unexpected error while loading dream: $e');
    }
  }
}