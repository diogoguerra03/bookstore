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

  @override
  void initState() {
    super.initState();
    // Faz as queries para cada género
    adventureBooks = BookService().fetchBooks('subject=adventure');
    fantasyBooks = BookService().fetchBooks('subject=fantasy');
    horrorBooks = BookService().fetchBooks('subject=horror');
    mysteryBooks = BookService().fetchBooks('subject=mystery');
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
                      decoration: InputDecoration(
                        hintText: 'Filter by name, genre, etc...',
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
                    onPressed: () {
                      // Função de busca pode ser implementada aqui
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            buildBookSection('Adventure', adventureBooks),
            buildBookSection('Fantasy', fantasyBooks),
            buildBookSection('Horror', horrorBooks),
            buildBookSection('Mystery', mysteryBooks),
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
              const Icon(Icons
                  .arrow_forward), // Ícone de seta, pode ter uma ação de navegação
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
