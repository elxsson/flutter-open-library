import 'book.dart';
import 'author.dart';

class Subject {
  final String name;
  final int workCount;
  final List<Book> works;
  final List<Author> topAuthors;

  Subject({
    required this.name,
    required this.workCount,
    this.works = const [],
    this.topAuthors = const [],
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    final worksData = json['works'] as List<dynamic>? ?? [];
    final authorsData = json['authors'] as List<dynamic>? ?? [];

    return Subject(
      name: json['name']?.toString() ?? '',
      workCount: json['work_count'] is int ? json['work_count'] : 0,
      works: worksData
          .map((w) => Book.fromJson(w as Map<String, dynamic>))
          .toList(),
      topAuthors: authorsData
          .map((a) => Author.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}
