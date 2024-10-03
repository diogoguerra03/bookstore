import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';
import '../widgets/bottom_nav_bar.dart';
import 'genre_page.dart';
import 'detail_page.dart';
import 'package:logger/logger.dart';
import '../services/database_helper.dart';
import '../models/user_model.dart';

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
  bool isGenrePage = false; // Novo estado para controlar a navegação

  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  String _searchFilter = 'title';
  int _searchPage = 1;

  final List<String> _searchOptions = ['title', 'author', 'subject'];

  late Future<List<User>> _users;

  @override
  void initState() {
    super.initState();
    adventureBooks = BookService().fetchBooks('subject=adventure&limit=10', 1);
    fantasyBooks = BookService().fetchBooks('subject=fantasy&limit=10', 1);
    horrorBooks = BookService().fetchBooks('subject=horror&limit=10', 1);
    mysteryBooks = BookService().fetchBooks('subject=mystery&limit=10', 1);
    searchResults = Future.value([]);

    _users = DatabaseHelper().getAllUsers();

    _users.then((userList) {
      for (var user in userList) {
        Logger().i('User: ${user.username}');
      }
    }).catchError((error) {
      Logger().e('Error fetching users: $error');
    });
  }

  void _searchBooks() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        isSearching = true;
        _searchPage = 1;
        searchResults =
            BookService().fetchBooks('$_searchFilter=$query', _searchPage);
      });
    }
  }

  void _loadMoreSearchResults() {
    setState(() {
      _searchPage++;
      searchResults = BookService().fetchBooks(
          '$_searchFilter=${_searchController.text.trim()}', _searchPage);
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
        title: const Text('BookStore'),
      ),
      body: SingleChildScrollView(
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
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          _clearSearch();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(isSearching ? Icons.clear : Icons.search),
                    onPressed: () {
                      if (isSearching) {
                        _clearSearch();
                      } else {
                        _searchBooks();
                      }
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
            // Navegação para a página Library
          } else if (index == 2) {
            // Navegação para a página Profile
          }
        },
      ),
    );
  }

  Widget buildSearchBookItem(Book book) {
    String coverUrl = book.coverId != 0
        ? 'https://covers.openlibrary.org/b/id/${book.coverId}-L.jpg'
        : 'assets/images/No_Cover.jpg'; // Imagem alternativa

    return GestureDetector(
      onTap: () {
        // Navegação para a página de detalhes do livro
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              title: book.title,
              author: book.author,
              coverId: book.coverId,
              workId: book.workId,
              wantToRead: book.wantToRead ?? 0,
              readingCount: book.readingCount ?? 0,
              readCount: book.readCount ?? 0,
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
                    // Retorna uma imagem padrão em caso de erro
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
                      book.author.isNotEmpty
                          ? book.author
                          : 'No author available',
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
                physics:
                    const NeverScrollableScrollPhysics(), // Evitar scroll duplo
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return buildSearchBookItem(
                      books[index]); // Usar a nova função aqui
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
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  // Navega para a GenrePage ao clicar na seta
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

  Widget buildBookItem(Book book) {
    String coverUrl = book.coverId != 0
        ? 'https://covers.openlibrary.org/b/id/${book.coverId}-L.jpg'
        : 'assets/images/No_Cover.jpg';

    return GestureDetector(
      onTap: () {
        // Log o workId do livro
        Logger().i('Clicked on book with workId: ${book.workId}');
        // Navegação para a página de detalhes do livro
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              title: book.title,
              author: book.author,
              coverId: book.coverId,
              workId: book.workId,
              wantToRead: book.wantToRead ?? 0,
              readingCount: book.readingCount ?? 0,
              readCount: book.readCount ?? 0,
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
              book.author.isNotEmpty ? book.author : 'No author available',
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
