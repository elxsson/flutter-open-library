import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../widgets/book_cover.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/app_bottom_nav.dart';

class SearchScreen extends HookWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final query = useState('');
    final filter = useState('title');
    final results = useState<List<Book>>([]);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    useEffect(() {
      if (query.value.isEmpty) {
        results.value = [];
        isLoading.value = false;
        errorMessage.value = null;
        return null;
      }

      final timer = Timer(const Duration(milliseconds: 400), () async {
        isLoading.value = true;
        errorMessage.value = null;

        try {
          final service = BookService();
          List<Book> books;

          switch (filter.value) {
            case 'author':
              books = await service.search(author: query.value);
              break;
            case 'subject':
              books = await service.search(subject: query.value);
              break;
            default:
              books = await service.search(query: query.value);
          }

          results.value = books;
          isLoading.value = false;
        } catch (e) {
          isLoading.value = false;
          errorMessage.value = 'Erro ao buscar livros. Tente novamente.';
        }
      });

      return timer.cancel;
    }, [query.value, filter.value]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 700 ? 700.0 : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: maxWidth,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SearchBarWidget(
                      onChanged: (value) {
                        query.value = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Título',
                          selected: filter.value == 'title',
                          onTap: () => filter.value = 'title',
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Autor',
                          selected: filter.value == 'author',
                          onTap: () => filter.value = 'author',
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Assunto',
                          selected: filter.value == 'subject',
                          onTap: () => filter.value = 'subject',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildBody(
                      query: query.value,
                      isLoading: isLoading.value,
                      errorMessage: errorMessage.value,
                      results: results.value,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }

  Widget _buildBody({
    required String query,
    required bool isLoading,
    required String? errorMessage,
    required List<Book> results,
  }) {
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // retriggers via useEffect
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Digite algo para pesquisar',
              style: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Nenhum resultado encontrado',
              style: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (_, index) {
        final book = results[index];
        return _SearchResultItem(
          book: book,
          onTap: () {
            final olid = book.key.replaceAll('/works/', '');
            Get.toNamed('/book', arguments: olid);
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: BookCover(
                coverId: book.coverId,
                width: 80,
                height: 120,
                size: 'M',
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    if (book.authors.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.authors.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (book.firstPublishYear != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${book.firstPublishYear}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
