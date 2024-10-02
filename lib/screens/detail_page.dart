import 'package:bookstore/models/book_model.dart';
import 'package:flutter/material.dart';
import '../services/book_service.dart'; // Importa o serviço que busca os livros

class DetailPage extends StatefulWidget {
  final String title;
  final String author;
  final int coverId;
  final String workId; // Espera receber o workId do livro
  final int wantToRead;
  final int readingCount;
  final int readCount;

  const DetailPage({
    super.key,
    required this.title,
    required this.author,
    required this.coverId,
    required this.workId,
    this.wantToRead = 0,
    this.readingCount = 0,
    this.readCount = 0,
  });

  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  late Future<Book> bookDetails;

  @override
  void initState() {
    super.initState();
    // Busca os detalhes do livro com base no workId
    bookDetails = BookService().fetchBookDetails(widget.workId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: FutureBuilder<Book>(
        future: bookDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final book = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Capa do livro
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          'https://covers.openlibrary.org/b/id/${widget.coverId}-L.jpg',
                          height: 200,
                        ),
                      ),
                      const SizedBox(
                          width: 20), // Espaçamento entre a imagem e o texto
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title,
                                style: const TextStyle(fontSize: 24)),
                            Text(widget.author,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(
                                height:
                                    24), // Espaçamento antes das estatísticas
                            // Estatísticas do livro
                            Row(
                              children: [
                                const Icon(Icons.bookmark,
                                    size: 18), // Ícone para "Want to Read"
                                const SizedBox(width: 4),
                                const Text('Want to Read:',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(widget.wantToRead.toString(),
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(
                                height: 8), // Espaçamento entre as linhas
                            Row(
                              children: [
                                const Icon(Icons.open_in_new,
                                    size: 18), // Ícone para "Reading Count"
                                const SizedBox(width: 4),
                                const Text('Reading Count:',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(widget.readingCount.toString(),
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(
                                height: 8), // Espaçamento entre as linhas
                            Row(
                              children: [
                                const Icon(Icons.done,
                                    size: 18), // Ícone para "Read Count"
                                const SizedBox(width: 4),
                                const Text('Read Count:',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(widget.readCount.toString(),
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 20), // Espaçamento antes da seção de subjects
                  const Text('Subjects:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(
                      height: 4), // Espaço entre o título e os subjects
                  Text(
                    book.subjects
                        .take(10)
                        .join(', '), // Juntar os subjects com vírgulas
                    style: const TextStyle(
                        fontSize: 12), // Tamanho do texto dos subjects
                  ),
                  const SizedBox(height: 20), // Espaçamento antes da descrição
                  // Descrição do livro
                  const Text('Description:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(book.description),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No book details found.'));
          }
        },
      ),
    );
  }
}
