import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_playlist_page.dart';

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
  List<Map<String, String>> books = []; // Lista de livros da playlist
  late DatabaseReference playlistRef; // Referência da playlist
  String? playlistImageUrl;
  String playlistName = ''; // Para manter o nome atualizado

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
              books = bookValues.entries
                  .map((entry) => {
                        'title': entry.key.toString(),
                        'author': entry.value.toString()
                      })
                  .toList();
            });
          } else {
            setState(() {
              books = [];
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    // Remove o listener quando a página for destruída
    playlistRef.onDisconnect();
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
                    height: 250, width: 250, fit: BoxFit.cover)
                : const Icon(Icons.book, size: 100, color: Colors.blue),
            const SizedBox(height: 16),
            Text(playlistName.isNotEmpty ? playlistName : widget.playlistName,
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
                  // Função para filtrar os livros (opcional)
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
