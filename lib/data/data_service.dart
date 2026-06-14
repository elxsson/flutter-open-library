import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../models/book.dart';

enum TableStatus { idle, loading, ready, error }

class DataService {
  final BookService _bookService = BookService();

  final ValueNotifier<Map<String, dynamic>> tableStateNotifier = ValueNotifier({
    'status': TableStatus.idle,
    'dataObjects': <Book>[],
  });

  Future<void> carregarTrending() async {
    tableStateNotifier.value = {
      'status': TableStatus.loading,
      'dataObjects': <Book>[],
    };

    try {
      final books = await _bookService.fetchTrending();
      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': books,
      };
    } catch (e) {
      tableStateNotifier.value = {
        'status': TableStatus.error,
        'dataObjects': <Book>[],
        'error': e.toString(),
      };
    }
  }
}

final dataService = DataService();
