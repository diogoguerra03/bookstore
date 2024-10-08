import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';
import 'book_detail_page.dart'; // Certifique-se de importar a página de detalhes

class GenrePage extends StatefulWidget {
  final String genre;

  const GenrePage({super.key, required this.genre});

  @override
  GenrePageState createState() => GenrePageState();
}

class GenrePageState extends State<GenrePage> {
  late Future<List<Book>> booksByGenre;
  List<Book> books = [];
  int currentPage = 1; // Página atual para paginação
  bool isLoadingMore = false; // Flag para controlar carregamento adicional

  @override
  void initState() {
    super.initState();
    _loadMoreBooks(); // Carregar os livros iniciais
  }

  // Função para carregar mais livros
  void _loadMoreBooks() {
    setState(() {
      isLoadingMore = true;
    });

    BookService()
        .fetchBooks('subject=${widget.genre}&limit=10', currentPage)
        .then((newBooks) {
      setState(() {
        books.addAll(newBooks);
        isLoadingMore = false;
        currentPage++; // Incrementa a página para a próxima chamada
      });
    }).catchError((error) {
      setState(() {
        isLoadingMore = false;
      });
      // Tratar erros, mostrar mensagem de erro se necessário
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books - ${widget.genre}'),
      ),
      body: books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: books.length + 1, // +1 para o botão "Load More"
              itemBuilder: (context, index) {
                if (index < books.length) {
                  // Exibir livros
                  String coverUrl = books[index].coverId != 0
                      ? 'https://covers.openlibrary.org/b/id/${books[index].coverId}-L.jpg'
                      : 'assets/images/No_Cover.jpg'; // Imagem alternativa

                  return GestureDetector(
                    onTap: () {
                      // Navegar para a página de detalhes ao clicar no livro
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            title: books[index].title,
                            author: books[index].author,
                            coverId: books[index].coverId,
                            workId: books[index].workId,
                            wantToRead: books[index].wantToRead ?? 0,
                            readingCount: books[index].readingCount ?? 0,
                            readCount: books[index].readCount ?? 0,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Image.network(coverUrl),
                      title: Text(books[index].title),
                      subtitle: Text(books[index].author.isNotEmpty
                          ? books[index].author
                          : 'Unknown author'),
                    ),
                  );
                } else {
                  // Botão "Load More"
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: isLoadingMore
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _loadMoreBooks,
                              child: const Text('Load More'),
                            ),
                    ),
                  );
                }
              },
            ),
    );
  }
}
