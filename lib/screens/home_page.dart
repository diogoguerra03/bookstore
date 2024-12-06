import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';
import '../widgets/bottom_nav_bar.dart';
import 'genre_page.dart';
import 'book_detail_page.dart';
import 'package:logger/logger.dart';
import 'auth/profile_page.dart';
import 'library_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<Book>> newestBooks;
  late Future<List<Book>> relevanceBooks;
  late Future<List<Book>> searchResults;
  bool isGenrePage = false;
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  String _searchFilter = 'intitle';
  int _searchPage = 1;

  final List<String> _searchOptions = ['intitle', 'inauthor', 'subject'];

  final List<String> categoriesName = [
    "Fiction",
    "Classic",
    "Romance",
    "Mystery",
    "Fantasy",
    "History",
    "Comic",
    "Crime",
  ];

  final List<String> categoriesImage = [
    "https://images.unsplash.com/photo-1474932430478-367dbb6832c1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8ZmljdGlvbnxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1455885661740-29cbf08a42fa?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8Y2xhc3NpYyUyMGJvb2tzfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1474552226712-ac0f0961a954?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cm9tYW5jZSUyMGJvb2tzfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1587876931567-564ce588bfbd?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MjB8fG15c3RlcnklMjBib29rc3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1439902315629-cd882022cea0?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8ZmFudGFzeSUyMGJvb2tzfGVufDB8MnwwfHw%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1562673005-7693bd6d6e54?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8aGlzdG9yeXxlbnwwfDJ8MHx8&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1608889476561-6242cfdbf622?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OXx8Y29taWN8ZW58MHwyfDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1625449281218-cbb6183f0aec?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8Y3JpbWV8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60",
  ];

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
      newestBooks = BookService().fetchBooks('orderBy:newest', 1);
      relevanceBooks = BookService().fetchBooks('orderBy:relevance', 1);

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

  bool isLoadingMore = false; // Flag para o botão de carregar mais

  void _loadMoreSearchResults() async {
    setState(() {
      isLoadingMore = true; // Mostra o círculo de carregamento no botão
    });

    try {
      List<Book> newBooks = await BookService().fetchBooks(
          '$_searchFilter:${_searchController.text.trim()}',
          _searchPage + 1 // Incrementa a página
          );

      List<Book> currentResults = await searchResults;

      setState(() {
        searchResults = Future.value([...currentResults, ...newBooks]);
        _searchPage++; // Incrementa o número da página
        isLoadingMore = false; // Esconde o círculo de carregamento
      });
    } catch (e) {
      Logger().e("Error loading more search results: $e");
      setState(() {
        isLoadingMore = false;
      });
    }
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
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                        buildBookSection('Newest', newestBooks),
                        buildBookSection('Relevance', relevanceBooks),
                      ],
                    ),

                  if (!isSearching) ...[
                    const SizedBox(height: 18),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Imagens de categorias
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 4 / 2.5,
                        ),
                        itemCount: categoriesName.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GenrePage(
                                    genre: categoriesName[index],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(categoriesImage[index]),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.3),
                                    BlendMode.darken,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  categoriesName[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]
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
              Center(
                child: isLoadingMore
                    ? const CircularProgressIndicator() // Mostra o círculo de carregamento no botão
                    : TextButton(
                        onPressed: _loadMoreSearchResults,
                        child: const Text('Load more results'),
                      ),
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
