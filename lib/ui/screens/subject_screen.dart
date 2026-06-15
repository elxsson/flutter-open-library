import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../models/subject.dart';
import '../../services/book_service.dart';
import '../widgets/book_cover.dart';

const _pageSize = 12;

class SubjectScreen extends HookWidget {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjectName = Get.arguments as String? ?? '';
    final subject = useState<Subject?>(null);
    final works = useState<List<Book>>([]);
    final offset = useState(0);
    final isLoading = useState(true);
    final isLoadingMore = useState(false);
    final errorMessage = useState<String?>(null);
    final scrollController = useScrollController();

    useEffect(() {
      Future.microtask(() async {
        offset.value = 0;
        isLoading.value = true;
        errorMessage.value = null;
        try {
          final result =
              await BookService().fetchSubject(subjectName, limit: _pageSize, offset: 0);
          subject.value = result;
          works.value = result.works;
          offset.value = _pageSize;
          isLoading.value = false;
        } catch (e) {
          isLoading.value = false;
          errorMessage.value = 'Erro ao carregar assunto.';
        }
      });
      return null;
    }, [subjectName]);

    useEffect(() {
      void listener() {
        if (scrollController.position.pixels >=
                scrollController.position.maxScrollExtent - 200 &&
            !isLoadingMore.value &&
            subject.value != null &&
            works.value.length < subject.value!.workCount) {
          isLoadingMore.value = true;
          Future.microtask(() async {
            try {
              final result = await BookService()
                  .fetchSubject(subjectName, limit: _pageSize, offset: offset.value);
              works.value = [...works.value, ...result.works];
              offset.value += _pageSize;
              isLoadingMore.value = false;
            } catch (e) {
              isLoadingMore.value = false;
            }
          });
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [subjectName, subject.value?.workCount]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(subjectName.isNotEmpty
            ? subjectName[0].toUpperCase() + subjectName.substring(1)
            : 'Assunto'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 700 ? 700.0 : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: maxWidth,
              child: _buildBody(
                context,
                subject.value,
                works.value,
                isLoading.value,
                isLoadingMore.value,
                errorMessage.value,
                scrollController,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    Subject? subject,
    List<Book> works,
    bool isLoading,
    bool isLoadingMore,
    String? errorMessage,
    ScrollController scrollController,
  ) {
    if (isLoading) {
      return _ShimmerLoading();
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

    if (subject == null) {
      return const Center(child: Text('Assunto não encontrado'));
    }

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _subjectIcon(subject.name),
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name[0].toUpperCase() + subject.name.substring(1),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${subject.workCount} livros',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (subject.topAuthors.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.accent),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        'Autores em destaque',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...subject.topAuthors.take(5).map((author) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 2),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.accent.withValues(alpha: 0.3),
                            child: Text(
                              author.name.isNotEmpty
                                  ? author.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            author.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 8),
                const Divider(color: AppColors.accent),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.menu_book, size: 18, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Livros',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final book = works[index];
                return _SubjectBookItem(
                  book: book,
                  onTap: () {
                    final olid = book.key.replaceAll('/works/', '');
                    Get.toNamed('/book', arguments: olid);
                  },
                );
              },
              childCount: works.length,
            ),
          ),
        ),
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }

  IconData _subjectIcon(String name) {
    switch (name.toLowerCase()) {
      case 'fiction':
        return Icons.auto_stories;
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history;
      case 'romance':
        return Icons.favorite;
      case 'fantasy':
        return Icons.auto_stories;
      case 'philosophy':
        return Icons.psychology;
      case 'mystery':
        return Icons.visibility;
      case 'biography':
        return Icons.person;
      case 'poetry':
        return Icons.lyrics;
      case 'drama':
        return Icons.theater_comedy;
      default:
        return Icons.category;
    }
  }
}

class _SubjectBookItem extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _SubjectBookItem({required this.book, required this.onTap});

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

class _ShimmerLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _shimmerRow(context),
        const SizedBox(height: 24),
        _shimmerGrid(context),
      ],
    );
  }

  Widget _shimmerRow(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120, height: 16,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 80, height: 12,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _shimmerGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 60, height: 16,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(2, (_) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: _ == 0 ? 0 : 6,
                right: _ == 1 ? 0 : 6,
              ),
              child: Column(
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12, width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 10, width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ),
      ],
    );
  }
}
