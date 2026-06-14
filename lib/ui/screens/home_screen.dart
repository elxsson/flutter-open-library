import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../data/data_service.dart';
import '../../models/book.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/book_card.dart';
import '../widgets/subject_chip.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  static const _popularSubjects = [
    'fiction',
    'science',
    'history',
    'romance',
    'fantasy',
    'philosophy',
  ];

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      dataService.carregarTrending();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Finder'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 700 ? 700.0 : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: maxWidth,
              child: ValueListenableBuilder(
                valueListenable: dataService.tableStateNotifier,
                builder: (_, value, __) {
                  final status = value['status'] as TableStatus;
                  final books = value['dataObjects'] as List<Book>;

                  if (status == TableStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (status == TableStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar dados',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => dataService.carregarTrending(),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Em alta',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (books.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: Text('Nenhum livro disponível')),
                          )
                        else
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: books.length,
                              itemBuilder: (_, index) {
                                final book = books[index];
                                return BookCard(
                                  book: book,
                                  onTap: () {
                                    final olid = book.key.replaceAll('/works/', '');
                                    Get.toNamed('/book', arguments: olid);
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 24),
                        Text(
                          'Categorias',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _popularSubjects.map((subject) {
                            return SubjectChip(
                              label: subject,
                              onTap: () => Get.toNamed('/subject', arguments: subject),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
