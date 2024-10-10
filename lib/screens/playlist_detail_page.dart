import 'dart:async'; // Para usar debounce
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_playlist_page.dart';
import 'book_detail_page.dart'; // Importe a página de detalhes do livro
import '../models/book_model.dart'; // Importe o modelo de livro

class PlaylistDetailPage extends StatefulWidget {
  final String playlistId;
  final String playlistName;
  final String? imageUrl;

  const PlaylistDetailPage({
    required this.playlistId,
    required this.playlistName,
    this.imageUrl,
    super.key,
  });

  @override
  PlaylistDetailPageState createState() => PlaylistDetailPageState();
}

class PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Book> books = []; // Lista de objetos do tipo Book
  List<Book> filteredBooks = []; // Lista de livros filtrados
  String searchTerm = '';
  String filterBy = 'title'; // Opções: 'title' ou 'author'
  late DatabaseReference playlistRef; // Referência da playlist
  String? playlistImageUrl;
  String playlistName = ''; // Para manter o nome atualizado
  Timer? _debounce; // Debounce timer para melhorar performance

  @override
  void initState() {
    super.initState();
    _addPlaylistListener(); // Adiciona o listener para escutar mudanças em tempo real
  }

  // Adiciona um listener para escutar mudanças na playlist em tempo real
  void _addPlaylistListener() {
    User? user = _auth.currentUser;
    if (user != null) {
      playlistRef = _database.ref('bookshelf/${user.uid}/${widget.playlistId}');

      // Listener para mudanças no conteúdo da playlist (nome, imagem e livros)
      playlistRef.onValue.listen((event) {
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> values =
              event.snapshot.value as Map<dynamic, dynamic>;

          // Atualiza o nome da playlist
          if (values.containsKey('name')) {
            setState(() {
              playlistName = values['name'] as String;
            });
          }

          // Atualiza a imagem da playlist
          if (values.containsKey('image') && values['image'] != '') {
            setState(() {
              playlistImageUrl = values['image'] as String?;
            });
          } else {
            setState(() {
              playlistImageUrl = null;
            });
          }

          // Atualiza a lista de livros
          if (values.containsKey('books')) {
            Map<dynamic, dynamic> bookValues =
                values['books'] as Map<dynamic, dynamic>;
            setState(() {
              books = bookValues.entries.map((entry) {
                Map<dynamic, dynamic> bookData =
                    entry.value as Map<dynamic, dynamic>;
                return Book(
                  id: entry.key, // bookId como chave
                  title: bookData['title'] ?? 'Unknown Title',
                  authors: List<String>.from(
                      bookData['authors'] ?? ['Unknown Author']),
                  publisher: bookData['publisher'] ?? 'Unknown Publisher',
                  categories: List<String>.from(
                      bookData['categories'] ?? ['Unknown Category']),
                  pageCount: bookData['pageCount'] ?? 0,
                  publishedDate: bookData['publishedDate'] ?? '',
                  averageRating: (bookData['averageRating'] ?? 0).toDouble(),
                  ratingsCount: bookData['ratingsCount'] ?? 0,
                  description: bookData['description'] ?? '',
                  coverUrl: bookData['coverUrl'] ?? '',
                );
              }).toList();
              _filterBooks(); // Aplica o filtro aos livros
            });
          } else {
            setState(() {
              books = [];
              filteredBooks = [];
            });
          }
        }
      });
    }
  }

  // Filtra os livros com base no título ou autor
  void _filterBooks() {
    setState(() {
      filteredBooks = books.where((book) {
        if (filterBy == 'title') {
          return book.title.toLowerCase().contains(searchTerm.toLowerCase());
        } else {
          return book.authors.any((author) =>
              author.toLowerCase().contains(searchTerm.toLowerCase()));
        }
      }).toList();
    });
  }

  // Função de debounce para melhorar a performance ao digitar
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        searchTerm = value;
        _filterBooks();
      });
    });
  }

  @override
  void dispose() {
    // Remove o listener e cancela o debounce timer
    playlistRef.onDisconnect();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight:
                300.0, // Mantém o tamanho da imagem e da área superior
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  const SizedBox(height: 100),
                  // Imagem da playlist
                  playlistImageUrl != null
                      ? Image.network(
                          playlistImageUrl!,
                          height: 150, // Mantém a altura da imagem
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.book, size: 100, color: Colors.blue),
                  const SizedBox(height: 16),
                  // Nome da playlist
                  Text(
                      playlistName.isNotEmpty
                          ? playlistName
                          : widget.playlistName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${filteredBooks.length} books',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPlaylistPage(
                        playlistId: widget.playlistId,
                        playlistName: playlistName.isNotEmpty
                            ? playlistName
                            : widget.playlistName,
                        imageUrl: playlistImageUrl ?? widget.imageUrl,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: _SliverAppBarDelegate(
              minHeight: 140.0, // Altura mínima da barra de pesquisa
              maxHeight: 140.0, // Altura máxima da barra de pesquisa
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0), // Ajusta o padding
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Filter by: "),
                        DropdownButton<String>(
                          value: filterBy,
                          items: const [
                            DropdownMenuItem(
                                value: 'title', child: Text('Title')),
                            DropdownMenuItem(
                                value: 'author', child: Text('Author')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              filterBy = value!;
                              _filterBooks();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                        height:
                            8), // Espaçamento entre dropdown e barra de pesquisa
                    // Barra de pesquisa
                    TextField(
                      controller: TextEditingController(text: searchTerm),
                      decoration: InputDecoration(
                        hintText: 'Filter by $filterBy...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchTerm.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    searchTerm = '';
                                    _filterBooks();
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final book = filteredBooks[index];
                return ListTile(
                  leading: book.coverUrl.isNotEmpty
                      ? Image.network(book.coverUrl,
                          width: 50, height: 50, fit: BoxFit.contain)
                      : const Icon(Icons.book, size: 50, color: Colors.blue),
                  title: Text(book.title),
                  subtitle: Text(book.authors.isNotEmpty
                      ? book.authors.join(', ')
                      : 'Unknown Author'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailPage(book: book),
                      ),
                    );
                  },
                );
              },
              childCount: filteredBooks.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
