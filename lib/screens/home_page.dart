import 'package:flutter/material.dart';
import '../services/book_service.dart'; // Serviço que busca os livros da API
import '../models/book_model.dart'; // Modelo dos livros
import '../widgets/bottom_nav_bar.dart'; // Barra de navegação inferior

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<Book>> adventureBooks;
  late Future<List<Book>> fantasyBooks;
  late Future<List<Book>> horrorBooks;
  late Future<List<Book>> mysteryBooks;
  late Future<List<Book>> searchResults; // Resultados da pesquisa

  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false; // Para alternar entre pesquisa e géneros

  @override
  void initState() {
    super.initState();
    // Faz as queries para cada género
    adventureBooks = BookService().fetchBooks('subject=adventure&limit=10');
    fantasyBooks = BookService().fetchBooks('subject=fantasy&limit=10');
    horrorBooks = BookService().fetchBooks('subject=horror&limit=10');
    mysteryBooks = BookService().fetchBooks('subject=mystery&limit=10');
    searchResults = BookService().fetchBooks('title='); // Inicialmente vazio
  }

  // Função para realizar a pesquisa
  void _searchBooks() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        isSearching = true;
        searchResults =
            BookService().fetchBooks('title=$query'); // Pesquisar por título
      });
    } else {
      setState(() {
        isSearching = false; // Voltar aos géneros se a pesquisa estiver vazia
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books by Genre'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adiciona a barra de pesquisa
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by title...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchBooks, // Chama a função de pesquisa
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Verifica se o utilizador está a pesquisar
            if (isSearching)
              buildSearchResults(searchResults) // Exibir resultados da pesquisa
            else
              // Exibe as secções de livros por género
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBookSection('Adventure', adventureBooks),
                  buildBookSection('Fantasy', fantasyBooks),
                  buildBookSection('Horror', horrorBooks),
                  buildBookSection('Mystery', mysteryBooks),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Índice da página atual (Home)
        onTap: (index) {
          if (index == 1) {
            // Função para navegação para a página Library
          } else if (index == 2) {
            // Função para navegação para a página Profile
          }
        },
      ),
    );
  }

  // Função para exibir os resultados da pesquisa
  Widget buildSearchResults(Future<List<Book>> searchResultsFuture) {
    return FutureBuilder<List<Book>>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<Book> books = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Evita scroll duplo
            itemCount: books.length,
            itemBuilder: (context, index) {
              return buildBookItem(books[index]);
            },
          );
        } else {
          return const Center(child: Text('No books found'));
        }
      },
    );
  }

  // Função para criar uma secção de livros de acordo com o género
  Widget buildBookSection(String genre, Future<List<Book>> booksFuture) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                genre,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_forward), // Ícone de seta
            ],
          ),
        ),
        SizedBox(
          height: 200, // Altura da área onde os livros vão aparecer
          child: FutureBuilder<List<Book>>(
            future: booksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                List<Book> books = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    return buildBookItem(books[index]);
                  },
                );
              } else {
                return const Center(child: Text('No books found'));
              }
            },
          ),
        ),
      ],
    );
  }

  // Função para construir um item de livro
  Widget buildBookItem(Book book) {
    // Constroi a URL da capa usando o campo cover_i
    String coverUrl = book.coverId != null
        ? 'https://covers.openlibrary.org/b/id/${book.coverId}-L.jpg'
        : '';

    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: coverUrl.isNotEmpty
                    ? NetworkImage(coverUrl)
                    : const AssetImage('assets/images/placeholder.png')
                        as ImageProvider, // Placeholder se não houver capa
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            style: const TextStyle(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            book.author.isNotEmpty ? book.author : 'No author available',
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
