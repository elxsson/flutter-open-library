import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/author.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../widgets/book_cover.dart';

class AuthorScreen extends HookWidget {
  const AuthorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final olid = Get.arguments as String? ?? '';
    final author = useState<Author?>(null);
    final works = useState<List<Book>>([]);
    final isLoading = useState(true);
    final errorMessage = useState<String?>(null);

    useEffect(() {
      () async {
        isLoading.value = true;
        errorMessage.value = null;
        try {
          final service = BookService();
          final results = await Future.wait([
            service.fetchAuthorDetails(olid),
            service.fetchAuthorWorks(olid),
          ]);
          author.value = results[0] as Author;
          works.value = results[1] as List<Book>;
          isLoading.value = false;
        } catch (e) {
          isLoading.value = false;
          errorMessage.value = 'Erro ao carregar dados do autor.';
        }
      }();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text(author.value?.name ?? 'Autor'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 700 ? 700.0 : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: maxWidth,
              child: _buildBody(
                author.value,
                works.value,
                isLoading.value,
                errorMessage.value,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    Author? author,
    List<Book> works,
    bool isLoading,
    String? errorMessage,
  ) {
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

    if (author == null) {
      return const Center(child: Text('Autor não encontrado'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _authorPhoto(olid: author.olid, size: 180),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            author.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (author.birthDate != null || author.deathDate != null) ...[
            const SizedBox(height: 8),
            Text(
              _formatDates(author.birthDate, author.deathDate),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
          ],
          if (author.bio != null && author.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              author.bio!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
          if (works.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(color: AppColors.accent),
            const SizedBox(height: 12),
            Text(
              'Obras (${works.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...works.map((book) => _WorkItem(
                  book: book,
                  onTap: () {
                    final olid = book.key.replaceAll('/works/', '');
                    Get.toNamed('/book', arguments: olid);
                  },
                )),
          ],
        ],
      ),
    );
  }

  String _formatDates(String? birth, String? death) {
    if (birth != null && death != null) return '$birth — $death';
    if (birth != null) return 'Nascimento: $birth';
    if (death != null) return 'Falecimento: $death';
    return '';
  }

  Widget _authorPhoto({required String? olid, required double size}) {
    if (olid == null) {
      return _photoPlaceholder(size);
    }

    final url = 'https://covers.openlibrary.org/a/olid/$olid-M.jpg';

    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (_, __) => _photoPlaceholder(size),
      errorWidget: (_, __, ___) => _photoPlaceholder(size),
    );
  }

  Widget _photoPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.4,
        color: AppColors.primary,
      ),
    );
  }
}

class _WorkItem extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _WorkItem({required this.book, required this.onTap});

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
                width: 70,
                height: 100,
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
                    if (book.firstPublishYear != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${book.firstPublishYear}',
                        style: TextStyle(
                          fontSize: 12,
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
