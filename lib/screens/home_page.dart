import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';
import '../widgets/bottom_nav_bar.dart';
import 'genre_page.dart';
import 'book_detail_page.dart'; // Certifique-se de que este nome está correto
import 'package:logger/logger.dart';
import 'auth/profile_page.dart';
import 'library_page.dart';

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
  late Future<List<Book>> searchResults;
  bool isGenrePage = false;
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  String _searchFilter = 'intitle';
  int _searchPage = 1;

  final List<String> _searchOptions = ['intitle', 'inauthor', 'subject'];

  @override
  void initState() {
    super.initState();
    _loadBooks(); // Inicia o carregamento dos livros
  }

  Future<void> _loadBooks() async {
    setState(() {
      isLoading = true; // Exibe o indicador de progresso
    });

    try {
      // Usar a Google Books API para buscar os dados
      adventureBooks = BookService().fetchBooks('subject:adventure', 1);
      fantasyBooks = BookService().fetchBooks('subject:fantasy', 1);
      horrorBooks = BookService().fetchBooks('subject:horror', 1);
      mysteryBooks = BookService().fetchBooks('subject:mystery', 1);

      // Simula um atraso de 1 segundo antes de carregar os livros
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      Logger().e('Error loading books: $e');
    } finally {
      setState(() {
        isLoading = false; // Oculta o indicador de progresso
      });
    }
  }

  void _searchBooks() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        isSearching = true;
        _searchPage = 1;
        searchResults =
            BookService().fetchBooks('$_searchFilter:$query', _searchPage);
      });
    }
  }

  void _loadMoreSearchResults() {
    setState(() {
      _searchPage++;
      searchResults = BookService().fetchBooks(
          '$_searchFilter:${_searchController.text.trim()}', _searchPage);
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('BookStore'), automaticallyImplyLeading: false),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Exibe o loading
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de pesquisa
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 20,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: _clearSearch,
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _searchBooks(); // Mantém a funcionalidade de pesquisar
                          },
                        ),
                      ],
                    ),
                  ),
                  // Dropdown para selecionar tipo de pesquisa
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: DropdownButton<String>(
                      value: _searchFilter,
                      items: _searchOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text('Search by $option'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _searchFilter = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isSearching)
                    buildSearchResults(searchResults)
                  else
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
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LibraryPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildSearchBookItem(Book book) {
    String coverUrl =
        book.coverUrl.isNotEmpty ? book.coverUrl : 'assets/images/No_Cover.jpg';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailPage(
              book: book, // Passa o objeto do livro diretamente
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  coverUrl,
                  height: 80,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Image.asset('assets/images/No_Cover.jpg',
                        height: 80, width: 60);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.authors.isNotEmpty
                          ? book.authors[0]
                          : 'Unknown Author',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return buildSearchBookItem(books[index]);
                },
              ),
              TextButton(
                onPressed: _loadMoreSearchResults,
                child: const Text('Load more results'),
              ),
            ],
          );
        } else {
          return const Center(child: Text('No books found'));
        }
      },
    );
  }

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
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenrePage(genre: genre),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
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

  Widget buildBookItem(Book book) {
    String coverUrl =
        book.coverUrl.isNotEmpty ? book.coverUrl : 'assets/images/No_Cover.jpg';

    return GestureDetector(
      onTap: () {
        Logger().i('Clicked on book with ID: ${book.id}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailPage(
              book: book,
            ),
          ),
        );
      },
      child: Container(
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
                  image: coverUrl.contains('http')
                      ? NetworkImage(coverUrl)
                      : AssetImage(coverUrl) as ImageProvider,
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
              book.authors.isNotEmpty ? book.authors[0] : 'Unknown Author',
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
