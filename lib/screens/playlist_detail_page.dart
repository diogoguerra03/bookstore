import 'dart:async'; // Para usar debounce
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_playlist_page.dart';
import 'book_detail_page.dart'; // Importe a página de detalhes do livro
import '../models/book_model.dart'; // Importe o modelo de livro

class PlaylistDetailPage extends StatefulWidget {
  final String playlistId; // Agora recebemos o ID da playlist
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
      appBar: AppBar(
        title:
            Text(playlistName.isNotEmpty ? playlistName : widget.playlistName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Função para editar playlist
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPlaylistPage(
                    playlistId: widget.playlistId, // Agora passamos o ID
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Imagem e informações da playlist
            playlistImageUrl != null
                ? Image.network(playlistImageUrl!,
                    height: 150, width: 150, fit: BoxFit.cover)
                : const Icon(Icons.book, size: 100, color: Colors.blue),
            const SizedBox(height: 16),
            Text(playlistName.isNotEmpty ? playlistName : widget.playlistName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${filteredBooks.length} books',
                style: const TextStyle(color: Colors.grey)),

            // Dropdown para escolher entre título ou autor
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Filter by: "),
                  DropdownButton<String>(
                    value: filterBy,
                    items: const [
                      DropdownMenuItem(value: 'title', child: Text('Title')),
                      DropdownMenuItem(value: 'author', child: Text('Author')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        filterBy = value!;
                        _filterBooks(); // Atualiza o filtro ao mudar o critério
                      });
                    },
                  ),
                ],
              ),
            ),

            // Barra de pesquisa
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextField(
                controller: TextEditingController(text: searchTerm),
                decoration: InputDecoration(
                  hintText: 'Filter by $filterBy...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  // Lupa à esquerda
                  prefixIcon: const Icon(Icons.search),
                  // "X" à direita
                  suffixIcon: searchTerm.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchTerm = '';
                              _filterBooks(); // Limpa a pesquisa e atualiza a lista
                            });
                          },
                        )
                      : null, // Não mostra o "X" se o campo estiver vazio
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Verifica se há livros na playlist
            if (books.isEmpty)
              const Center(child: Text("No books available in this playlist")),
            // Verifica se o filtro resultou em livros
            if (filteredBooks.isEmpty && books.isNotEmpty)
              const Center(child: Text("No books found matching your search")),

            // Lista de livros
            if (filteredBooks.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return ListTile(
                      leading: book.coverUrl.isNotEmpty
                          ? Image.network(book.coverUrl,
                              width: 50, height: 50, fit: BoxFit.contain)
                          : const Icon(Icons.book,
                              size: 50, color: Colors.blue),
                      title: Text(book.title),
                      subtitle: Text(book.authors.isNotEmpty
                          ? book.authors.join(', ')
                          : 'Unknown Author'),
                      onTap: () {
                        // Abre a página de detalhes do livro
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailPage(book: book),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
