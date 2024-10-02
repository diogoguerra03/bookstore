import 'package:flutter/material.dart';
import '../services/book_service.dart'; // Serviço que busca os livros da API
import '../models/book_model.dart'; // Modelo dos livros

class GenrePage extends StatefulWidget {
  final String genre; // O gênero selecionado

  const GenrePage({super.key, required this.genre});

  @override
  GenrePageState createState() => GenrePageState();
}

class GenrePageState extends State<GenrePage> {
  late Future<List<Book>> booksByGenre;

  @override
  void initState() {
    super.initState();
    // Busca os livros do gênero passado via construtor
    booksByGenre = BookService().fetchBooks('subject=${widget.genre}', 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Books - ${widget.genre}'), // Título com o gênero selecionado
      ),
      body: FutureBuilder<List<Book>>(
        future: booksByGenre,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Book> books = snapshot.data!;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: books[index].coverId != null
                      ? Image.network(
                          'https://covers.openlibrary.org/b/id/${books[index].coverId}-L.jpg')
                      : const Icon(Icons.book),
                  title: Text(books[index].title),
                  subtitle: Text(books[index].author.isNotEmpty
                      ? books[index].author
                      : 'Unknown author'),
                );
              },
            );
          } else {
            return const Center(child: Text('No books found'));
          }
        },
      ),
    );
  }
}
