import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Capa do livro
              Center(
                child: Image.network(
                  book.coverUrl,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/images/No_Cover.jpg',
                        height: 200);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Título
              Text(
                book.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Autores
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

              // Publisher e Data de Publicação
              Row(
                children: [
                  const Icon(Icons.business, size: 20),
                  const SizedBox(width: 8),
                  Text('Publisher: ${book.publisher}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Text('Published: ${book.publishedDate}'),
                ],
              ),
              const SizedBox(height: 16),

              // Classificação e contagem de avaliações
              Row(
                children: [
                  const Icon(Icons.star, size: 20),
                  const SizedBox(width: 8),
                  Text('Rating: ${book.averageRating}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.rate_review, size: 20),
                  const SizedBox(width: 8),
                  Text('Reviews: ${book.ratingsCount}'),
                ],
              ),
              const SizedBox(height: 16),

              // Número de páginas
              Row(
                children: [
                  const Icon(Icons.menu_book, size: 20),
                  const SizedBox(width: 8),
                  Text('Page Count: ${book.pageCount}'),
                ],
              ),
              const SizedBox(height: 16),

              // Categorias
              Row(
                children: [
                  const Icon(Icons.category, size: 20),
                  const SizedBox(width: 8),
                  Text('Categories: ${book.categories.join(', ')}'),
                ],
              ),
              const SizedBox(height: 16),

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
}
