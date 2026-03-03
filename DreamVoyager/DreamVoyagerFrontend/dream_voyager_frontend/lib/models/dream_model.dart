class Dream {
  Dream({
    required this.id,
    required this.content,
    required this.moodScore,
    required this.isLucid,
    required this.tags,
    this.createdAt,
  });

  final String id;
  final String content;
  final double moodScore;
  final bool isLucid;
  final List<String> tags;
  final DateTime? createdAt;

  String get title {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return 'Untitled Dream';
    }
    final words = trimmed.split(RegExp(r'\s+'));
    return words.take(5).join(' ');
  }

  factory Dream.fromJson(Map<String, dynamic> json) {
    final dynamic rawTags = json['tags'];
    final List<String> parsedTags;

    if (rawTags is String) {
      parsedTags = rawTags
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    } else if (rawTags is List) {
      parsedTags = rawTags
          .map((tag) => tag.toString().trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    } else {
      parsedTags = <String>[];
    }

    return Dream(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      moodScore: (json['mood_score'] as num?)?.toDouble() ?? 0.0,
      isLucid: json['is_lucid'] == true ||
          json['is_lucid']?.toString() == '1' ||
          json['is_lucid']?.toString().toLowerCase() == 'true',
      tags: parsedTags,
      createdAt: DateTime.tryParse(
        json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'mood_score': moodScore,
      'is_lucid': isLucid,
      'tags': tags,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}