import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/dream_model.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  static const Duration _requestTimeout = Duration(seconds: 12);

  Future<List<Dream>> fetchDreams() async {
    final Uri url = Uri.parse('$_baseUrl/dreams');
    debugPrint('[ApiService] GET $url');

    try {
      final response = await http.get(url).timeout(_requestTimeout);
      debugPrint('[ApiService] GET $url -> ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load dreams (HTTP ${response.statusCode}).',
        );
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded is List
          ? decoded
          : (decoded is Map<String, dynamic> && decoded['data'] is List
              ? decoded['data'] as List<dynamic>
              : <dynamic>[]);

      return list
          .map((item) => Dream.fromJson(item as Map<String, dynamic>))
          .toList();
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

  Future<Dream> saveDream(
    String content, {
    double moodScore = 0.0,
    bool isLucid = false,
    List<String> tags = const <String>[],
  }) async {
    final Uri url = Uri.parse('$_baseUrl/dreams');
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
}