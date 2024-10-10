import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import '../models/book_model.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  BookDetailPage({super.key, required this.book});

  void _showPlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlaylistDialog(book: book); // Passa o objeto completo do livro
      },
    );
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
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
                            Text('Publisher: ${book.publisher}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.category, size: 20),
                            const SizedBox(width: 8),
                            Text('Categories: ${book.categories.join(', ')}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Center(
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
                        value: book.averageRating.toString(),
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
              const SizedBox(height: 40),
              const Text(
                'Description:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                book.description,
                style: const TextStyle(fontSize: 16),
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

  Future<void> _loadPlaylists() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      String uid = auth.currentUser!.uid;

      DatabaseReference playlistRef = database.child('bookshelf').child(uid);
      DataSnapshot snapshot = await playlistRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> playlists =
            Map<String, dynamic>.from(snapshot.value as Map);

        playlists.forEach((key, value) async {
          _selectedPlaylists[key] = false;
          _playlistNames[key] = value['name'] ?? 'Unnamed Playlist';

          // Verifica se o livro já está na playlist
          DataSnapshot booksSnapshot = await playlistRef
              .child(key)
              .child('books')
              .child(widget.book.id) // Verifica se o bookId existe como chave
              .get();

          _playlistDisabled[key] = booksSnapshot
              .exists; // Desativa checkbox se já estiver na playlist
        });
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
      _selectedPlaylists.forEach((playlistId, isSelected) {
        if (isSelected) {
          // Usar o bookId como chave e salvar todas as informações do livro
          userBookshelfRef
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
          });
        }
      });
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
