class Book {
  final String key;
  final String title;
  final List<String> authors;
  final List<String> authorKeys;
  final int? coverId;
  final int? firstPublishYear;
  final List<String> subjects;
  final String? description;

  Book({
    required this.key,
    required this.title,
    this.authors = const [],
    this.authorKeys = const [],
    this.coverId,
    this.firstPublishYear,
    this.subjects = const [],
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    List<String> parseAuthors(dynamic data) {
      if (data is List) {
        return data.map((a) => a is String ? a : a['name']?.toString() ?? '').toList();
      }
      return [];
    }

    List<String> parseAuthorKeys(dynamic data) {
      if (data is List) {
        return data.map((a) => a is String ? a : a['key']?.toString() ?? '').toList();
      }
      return [];
    }

    List<String> parseSubjects(dynamic data) {
      if (data is List) {
        return data.map((s) => s.toString()).toList();
      }
      return [];
    }

    String? parseDescription(dynamic data) {
      if (data is String) return data;
      if (data is Map) return data['value']?.toString();
      return null;
    }

    return Book(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      authors: parseAuthors(json['authors']),
      authorKeys: parseAuthorKeys(json['authors']),
      coverId: json['cover_id'] is int
          ? json['cover_id']
          : json['covers'] is List
              ? (json['covers'] as List).firstOrNull
              : null,
      firstPublishYear: json['first_publish_year'] is int
          ? json['first_publish_year']
          : null,
      subjects: parseSubjects(json['subjects']),
      description: parseDescription(json['description']),
    );
  }

  factory Book.fromSearchJson(Map<String, dynamic> json) {
    List<String> parseAuthorNames(dynamic data) {
      if (data is List) return data.map((s) => s.toString()).toList();
      return [];
    }

    List<String> parseAuthorKeys(dynamic data) {
      if (data is List) return data.map((s) => s.toString()).toList();
      return [];
    }

    List<String> parseSubjects(dynamic data) {
      if (data is List) return data.map((s) => s.toString()).toList();
      return [];
    }

    return Book(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      authors: parseAuthorNames(json['author_name']),
      authorKeys: parseAuthorKeys(json['author_key']),
      coverId: json['cover_i'] is int ? json['cover_i'] : null,
      firstPublishYear: json['first_publish_year'] is int
          ? json['first_publish_year']
          : null,
      subjects: parseSubjects(json['subject']),
    );
  }
}
