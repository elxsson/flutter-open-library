import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String _baseUrl = 'https://openlibrary.org';

  Future<List<Book>> fetchTrending() async {
    final uri = Uri.parse('$_baseUrl/trending/daily.json');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to load trending books: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final works = data['works'] as List<dynamic>;

    return works.map((w) => Book.fromJson(w as Map<String, dynamic>)).toList();
  }

  Future<Map<String, String>> fetchAuthorInfo(String authorKey) async {
    final uri = Uri.parse('$_baseUrl/authors/$authorKey.json');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      return {'key': authorKey, 'name': authorKey};
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'key': data['key']?.toString() ?? authorKey,
      'name': data['name']?.toString() ?? authorKey,
    };
  }

  Future<Book> fetchBookDetail(String olid) async {
    final uri = Uri.parse('$_baseUrl/works/$olid.json');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to load book detail: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final authorsData = data['authors'] as List<dynamic>? ?? [];
    final authorKeys = <String>[];
    for (final a in authorsData) {
      final author = (a as Map<String, dynamic>)['author'] as Map<String, dynamic>?;
      final key = author?['key']?.toString();
      if (key != null) authorKeys.add(key);
    }

    final authorFutures = authorKeys.map((k) => fetchAuthorInfo(k));
    final authorInfos = await Future.wait(authorFutures);
    final authorNames = authorInfos.map((a) => a['name'] ?? '').toList();
    final parsedAuthorKeys = authorInfos.map((a) => a['key'] ?? '').toList();

    int? coverId;
    final covers = data['covers'];
    if (covers is List && covers.isNotEmpty) {
      coverId = covers.first as int?;
    }

    String? description;
    final desc = data['description'];
    if (desc is String) {
      description = desc;
    } else if (desc is Map) {
      description = desc['value']?.toString();
    }

    List<String> subjects = [];
    final subs = data['subjects'];
    if (subs is List) {
      subjects = subs.map((s) => s.toString()).toList();
    }

    return Book(
      key: data['key']?.toString() ?? '/works/$olid',
      title: data['title']?.toString() ?? '',
      authors: authorNames,
      authorKeys: parsedAuthorKeys,
      coverId: coverId,
      firstPublishYear: data['first_publish_year'] is int
          ? data['first_publish_year']
          : null,
      subjects: subjects,
      description: description,
    );
  }

  Future<List<Book>> search({
    String? query,
    String? author,
    String? subject,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
    };

    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    } else if (author != null && author.isNotEmpty) {
      params['author'] = author;
    } else if (subject != null && subject.isNotEmpty) {
      params['subject'] = subject;
    } else {
      return [];
    }

    final uri = Uri.parse('$_baseUrl/search.json').replace(queryParameters: params);
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to search books: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = data['docs'] as List<dynamic>;

    return docs.map((d) => Book.fromSearchJson(d as Map<String, dynamic>)).toList();
  }
}
