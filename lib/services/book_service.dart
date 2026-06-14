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
