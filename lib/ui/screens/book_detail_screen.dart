import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../widgets/book_cover.dart';
import '../widgets/subject_chip.dart';

class BookDetailScreen extends HookWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final olid = Get.arguments as String? ?? '';
    final book = useState<Book?>(null);
    final isLoading = useState(true);
    final errorMessage = useState<String?>(null);

    useEffect(() {
      Future.microtask(() async {
        isLoading.value = true;
        errorMessage.value = null;
        try {
          final result = await BookService().fetchBookDetail(olid);
          book.value = result;
          isLoading.value = false;
        } catch (e) {
          isLoading.value = false;
          errorMessage.value = 'Erro ao carregar detalhes do livro.';
        }
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.value?.title ?? 'Detalhes'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 700 ? 700.0 : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: maxWidth,
              child: _buildBody(book.value, isLoading.value, errorMessage.value),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(Book? book, bool isLoading, String? errorMessage) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage, style: const TextStyle(color: AppColors.primary)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Voltar'),
            ),
          ],
        ),
      );
    }

    if (book == null) {
      return const Center(child: Text('Livro não encontrado'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BookCover(
                coverId: book.coverId,
                width: 220,
                height: 320,
                size: 'L',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            book.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (book.authors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(book.authors.length, (i) {
                return TextButton(
                  onPressed: () {
                    final key = book.authorKeys.isNotEmpty
                        ? book.authorKeys[i].replaceAll('/authors/', '')
                        : '';
                    if (key.isNotEmpty) {
                      Get.toNamed('/author', arguments: key);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    book.authors[i],
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.accent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                );
              }),
            ),
          ],
          if (book.firstPublishYear != null) ...[
            const SizedBox(height: 8),
            Text(
              '${book.firstPublishYear}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
          ],
          if (book.description != null && book.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.accent),
            const SizedBox(height: 12),
            Text(
              'Descrição',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.description!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
          if (book.subjects.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.accent),
            const SizedBox(height: 12),
            Text(
              'Assuntos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: book.subjects.map((subject) {
                return SubjectChip(
                  label: subject,
                  onTap: () => Get.toNamed('/subject', arguments: subject),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
