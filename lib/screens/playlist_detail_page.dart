import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_playlist_page.dart';

class PlaylistDetailPage extends StatefulWidget {
  final String playlistName;
  final String? imageUrl;

  const PlaylistDetailPage(
      {required this.playlistName, this.imageUrl, super.key});

  @override
  PlaylistDetailPageState createState() => PlaylistDetailPageState();
}

class PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Map<String, String>> books = []; // Lista de livros da playlist

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  // Carregar os livros da playlist
  void _loadBooks() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference ref =
          _database.ref('bookshelf/${user.uid}/${widget.playlistName}/books');
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          books = values.entries
              .map((entry) => {
                    'title': entry.key.toString(),
                    'author': entry.value.toString()
                  })
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlistName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Função para editar playlist
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPlaylistPage(
                    playlistName: widget.playlistName,
                    imageUrl: widget.imageUrl,
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
            if (widget.imageUrl != null)
              Image.network(widget.imageUrl!,
                  height: 250, width: 250, fit: BoxFit.cover)
            else
              const Icon(Icons.book, size: 100, color: Colors.blue),
            const SizedBox(height: 16),
            Text(widget.playlistName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${books.length} books',
                style: const TextStyle(color: Colors.grey)),

            // Barra de pesquisa
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Filter by name, genre, etc...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) {
                  // Função para filtrar os livros
                },
              ),
            ),

            // Lista de livros
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return ListTile(
                    leading:
                        const Icon(Icons.book, size: 50, color: Colors.blue),
                    title: Text(book['title'] ?? 'Unknown Title'),
                    subtitle: Text(book['author'] ?? 'Unknown Author'),
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
