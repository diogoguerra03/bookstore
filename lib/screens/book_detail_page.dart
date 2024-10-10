import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha superior: capa à esquerda e título/autor/publisher/categorias à direita
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Capa do livro
                  SizedBox(
                    width: 120, // Definir a largura da capa
                    height: 180, // Definir a altura da capa
                    child: Image.network(
                      book.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/images/No_Cover.jpg',
                            fit: BoxFit.cover);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Título, Autor, Publisher e Categorias
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título em negrito
                        Text(
                          book.title,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // Autor com ícone de pessoa
                        Row(
                          children: [
                            const Icon(Icons.person, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              book.authors.isNotEmpty
                                  ? book.authors.join(', ')
                                  : 'Unknown Author',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Publisher
                        Row(
                          children: [
                            const Icon(Icons.business, size: 20),
                            const SizedBox(width: 8),
                            Text('Publisher: ${book.publisher}'),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Categorias
                        Row(
                          children: [
                            const Icon(Icons.category, size: 20),
                            const SizedBox(width: 8),
                            Text('Categories: ${book.categories.join(', ')}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Scroll horizontal com estatísticas, centralizado e maior
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Número de páginas
                      buildStatItem(
                        icon: Icons.menu_book,
                        label: 'Pages',
                        value: book.pageCount.toString(),
                      ),
                      const SizedBox(width: 32),

                      // Publicado
                      buildStatItem(
                        icon: Icons.calendar_today,
                        label: 'Published',
                        value: book.publishedDate,
                      ),
                      const SizedBox(width: 32),

                      // Rating
                      buildStatItem(
                        icon: Icons.star,
                        label: 'Rating',
                        value: book.averageRating.toString(),
                      ),
                      const SizedBox(width: 32),

                      // Reviews
                      buildStatItem(
                        icon: Icons.rate_review,
                        label: 'Reviews',
                        value: book.ratingsCount.toString(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Descrição
              const Text(
                'Description:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                book.description,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função para criar os itens de estatística no scroll horizontal
  Widget buildStatItem(
      {required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, size: 32), // Maior ícone
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)), // Valor maior
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: Colors.grey)), // Texto maior
      ],
    );
  }
}
