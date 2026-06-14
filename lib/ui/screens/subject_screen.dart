import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../models/subject.dart';
import '../../services/book_service.dart';
import '../widgets/book_cover.dart';

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
      () async {
        offset.value = 0;
        isLoading.value = true;
        errorMessage.value = null;
        try {
          final result =
              await BookService().fetchSubject(subjectName, offset: 0);
          subject.value = result;
          works.value = result.works;
          offset.value = 20;
          isLoading.value = false;
        } catch (e) {
          isLoading.value = false;
          errorMessage.value = 'Erro ao carregar assunto.';
        }
      }();
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
          () async {
            try {
              final result = await BookService()
                  .fetchSubject(subjectName, offset: offset.value);
              works.value = [...works.value, ...result.works];
              offset.value += 20;
              isLoadingMore.value = false;
            } catch (e) {
              isLoadingMore.value = false;
            }
          }();
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [subjectName, subject.value?.workCount]);

    return Scaffold(
      appBar: AppBar(
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
                Text(
                  subject.name[0].toUpperCase() + subject.name.substring(1),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject.workCount} livros',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                ),
                if (subject.topAuthors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Autores em destaque',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: subject.topAuthors.map((author) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.accent,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          author.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                const Divider(color: AppColors.accent),
                const SizedBox(height: 8),
                Text(
                  'Livros',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final book = works[index];
                return _GridBookItem(
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
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _GridBookItem extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _GridBookItem({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: BookCover(
                coverId: book.coverId,
                width: double.infinity,
                height: 160,
                size: 'M',
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                    if (book.authors.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        book.authors.first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
