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

    if (widget.genre != 'Newest' && widget.genre != 'Relevance') {
      // Carrega livros por gênero
      BookService()
          .fetchBooks('subject:${widget.genre}', currentPage)
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
    } else {
      // Carrega livros para Newest ou Relevance
      BookService()
          .fetchBooks('orderBy:${widget.genre}', currentPage)
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
                  String coverUrl = books[index].coverUrl.isNotEmpty
                      ? books[index].coverUrl
                      : 'assets/images/No_Cover.jpg'; // Fallback para imagem

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookDetailPage(book: books[index]),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        leading: SizedBox(
                          width: 50, // Definir largura da imagem
                          height: 80, // Definir altura da imagem
                          child: Image.network(
                            coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset('assets/images/No_Cover.jpg',
                                  fit: BoxFit.cover);
                            },
                          ),
                        ),
                        title: Text(
                          books[index].title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          books[index].authors.isNotEmpty
                              ? books[index].authors[0]
                              : 'No author available',
                        ),
                      ),
                    ),
                  );
                } else {
                  // Exibir botão "Load More"
                  return Center(
                    child: TextButton(
                      onPressed: isLoadingMore ? null : _loadMoreBooks,
                      child: isLoadingMore
                          ? const CircularProgressIndicator()
                          : const Text('Load More'),
                    ),
                  );
                }
              },
            ),
    );
  }
}
