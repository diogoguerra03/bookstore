import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book_model.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  BookDetailPage({super.key, required this.book});

  // Função para verificar se a URL pode ser aberta
  void _showPlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlaylistDialog(book: book); // Passa o objeto completo do livro
      },
    );
  }

  // Função para abrir a URL
  Future<void> _launchURL(String url) async {
    Uri uri = Uri.parse(url); // Converte a string em Uri
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () {
              _showPlaylistDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card com os principais detalhes do livro
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Capa do livro
                      SizedBox(
                        width: 120,
                        height: 180,
                        child: Image.network(
                          book.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/images/No_Cover.jpg',
                                fit: BoxFit.cover);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Informações do livro
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Ícone de informação para redirecionamento
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () {
                                    if (book.saleability != 'NOT_FOR_SALE') {
                                      _launchURL(book
                                          .saleInfoUrl); // Abre o link de venda
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Book not for sale.'),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    book.authors.isNotEmpty
                                        ? book.authors.join(', ')
                                        : 'Unknown Author',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.business, size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text('Publisher: ${book.publisher}'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.category, size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                      'Categories: ${book.categories.join(', ')}'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (book.saleability != 'NOT_FOR_SALE') ...[
                              Row(
                                children: [
                                  const Icon(Icons.attach_money, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                      'Price: ${book.amount} ${book.currencyCode}'),
                                ],
                              ),
                            ] else ...[
                              const Text(
                                'Price: Not for sale',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Estatísticas do livro (exibidas no centro)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildStatItem(
                            icon: Icons.menu_book,
                            label: 'Pages',
                            value: book.pageCount.toString(),
                          ),
                          const SizedBox(width: 32),
                          buildStatItem(
                            icon: Icons.calendar_today,
                            label: 'Published',
                            value: book.publishedDate,
                          ),
                          const SizedBox(width: 32),
                          buildStatItem(
                            icon: Icons.star,
                            label: 'Rating',
                            value: book.averageRating.toString() == '0.0'
                                ? 'N/A'
                                : book.averageRating.toString(),
                          ),
                          const SizedBox(width: 32),
                          buildStatItem(
                            icon: Icons.rate_review,
                            label: 'Reviews',
                            value: book.ratingsCount.toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Descrição do livro
              const Text(
                'Description:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  book.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatItem(
      {required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

// Dialog para selecionar playlists e salvar todas as informações do livro
class PlaylistDialog extends StatefulWidget {
  final Book book;

  const PlaylistDialog({super.key, required this.book});

  @override
  PlaylistDialogState createState() => PlaylistDialogState();
}

class PlaylistDialogState extends State<PlaylistDialog> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final Map<String, bool> _selectedPlaylists = {};
  final Map<String, String> _playlistNames = {};
  final Map<String, bool> _playlistDisabled =
      {}; // Para desativar as checkboxes
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  // Carrega as playlists do utilizador
  Future<void> _loadPlaylists() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      String uid = auth.currentUser!.uid;

      DatabaseReference playlistRef = database.child('bookshelf').child(uid);
      DataSnapshot snapshot = await playlistRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> playlists =
            Map<String, dynamic>.from(snapshot.value as Map);

        // Itera sobre as playlists e adiciona ao mapa
        for (String key in playlists.keys) {
          _selectedPlaylists[key] = false;
          _playlistNames[key] = playlists[key]['name'] ?? 'Unnamed Playlist';

          // Verifica se o livro já está na playlist
          DataSnapshot booksSnapshot = await playlistRef
              .child(key)
              .child('books')
              .child(widget.book.id) // Verifica se o bookId existe como chave
              .get();

          _playlistDisabled[key] = booksSnapshot.exists;

          if (!mounted) return;
        }
      }
    } catch (e) {
      Logger().e("Error loading playlists: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addToPlaylists() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      String uid = auth.currentUser!.uid;

      DatabaseReference userBookshelfRef =
          database.child('bookshelf').child(uid);

      DateTime now = DateTime.now();

      for (String playlistId in _selectedPlaylists.keys) {
        if (_selectedPlaylists[playlistId] == true) {
          await userBookshelfRef
              .child(playlistId)
              .child('books')
              .child(widget.book.id)
              .set({
            'bookId': widget.book.id,
            'title': widget.book.title,
            'authors': widget.book.authors,
            'publisher': widget.book.publisher,
            'categories': widget.book.categories,
            'pageCount': widget.book.pageCount,
            'publishedDate': widget.book.publishedDate,
            'averageRating': widget.book.averageRating,
            'ratingsCount': widget.book.ratingsCount,
            'description': widget.book.description,
            'coverUrl': widget.book.coverUrl,
            'saleability': widget.book.saleability,
            'amount': widget.book.amount,
            'currencyCode': widget.book.currencyCode,
            'saleInfoUrl': widget.book.saleInfoUrl,
            'addedAt': now.toIso8601String(),
          });
        }

        if (!mounted) return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              'Book added to playlists',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      Logger().e("Error adding to playlists: $e");
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Playlists'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _selectedPlaylists.keys.map((playlistId) {
                  return CheckboxListTile(
                    title: Text(_playlistNames[playlistId] ?? playlistId),
                    value: _selectedPlaylists[playlistId],
                    onChanged: _playlistDisabled[playlistId] == true
                        ? null
                        : (bool? value) {
                            setState(() {
                              _selectedPlaylists[playlistId] = value!;
                            });
                          },
                  );
                }).toList(),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addToPlaylists,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
