import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_page.dart';
import 'auth/profile_page.dart';
import 'playlist_detail_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  LibraryPageState createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Map<String, dynamic>> playlists =
      []; // Lista para armazenar as playlists (com ID e nome)
  Map<String, String?> playlistImages =
      {}; // Mapa para armazenar URLs das imagens das playlists
  Map<String, int> bookCounts =
      {}; // Mapa para armazenar a contagem de livros por playlist

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  // Carrega playlists do Realtime Database
  void _loadPlaylists() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference ref = _database.ref('bookshelf/${user.uid}');
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> loadedPlaylists = [];

        setState(() {
          playlistImages.clear(); // Limpa as imagens antigas
          bookCounts.clear(); // Limpa as contagens antigas

          values.forEach((key, value) async {
            String playlistId = key;
            String playlistName = value['name'] as String;

            loadedPlaylists.add({
              'id': playlistId,
              'name': playlistName,
            });

            // Carregar a imagem da playlist
            if (value.containsKey('image') && value['image'] != '') {
              playlistImages[playlistId] = value['image'] as String;
            } else {
              playlistImages[playlistId] = null; // Sem imagem
            }

            // Contar o número de livros
            if (value.containsKey('books')) {
              DataSnapshot booksSnapshot =
                  await ref.child('$playlistId/books').get();
              int bookCount = booksSnapshot.children.length;
              bookCounts[playlistId] = bookCount;
            } else {
              bookCounts[playlistId] = 0; // Playlist sem livros
            }
          });

          playlists = loadedPlaylists; // Atualiza a lista de playlists
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed:
                _addPlaylist, // Chama a função para adicionar uma nova playlist
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: playlists.isEmpty
            ? const Center(child: Text("No playlists available."))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 colunas
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8, // Ajusta a proporção dos cards
                ),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  String playlistId = playlists[index]['id'];
                  String playlistName =
                      playlists[index]['name']; // Obtém o nome da playlist
                  String? imageUrl = playlistImages[playlistId];
                  int bookCount = bookCounts[playlistId] ?? 0;

                  return GestureDetector(
                    onTap: () {
                      // Navega para a página de detalhes da playlist
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaylistDetailPage(
                            playlistId: playlistId, // Passa o ID da playlist
                            playlistName:
                                playlistName, // Passa o nome da playlist
                            imageUrl: imageUrl,
                          ),
                        ),
                      );
                    },
                    onLongPress: () =>
                        _showDeleteDialog(playlistId, playlistName),
                    child: Column(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1, // Mantém os cards quadrados
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.book, // Ícone padrão de livro
                                      size: 50,
                                      color: Colors.blue,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$playlistName - $bookCount books', // Exibe o nome da playlist
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            // Navegação para a página Home
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          } else if (index == 2) {
            // Navegação para a página Profile
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

  // Função para excluir uma playlist
  Future<void> _deletePlaylist(String playlistId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Remove a foto da playlist do Firebase Storage
      if (playlistImages[playlistId] != null) {
        await FirebaseStorage.instance
            .ref('bookshelf/${user.uid}/$playlistId')
            .delete();
      }

      // Remove a playlist do Realtime Database
      await _database.ref('bookshelf/${user.uid}/$playlistId').remove();
      _loadPlaylists(); // Recarrega as playlists após a exclusão
    }
  }

  // Função para adicionar uma nova playlist com verificação de duplicata
  Future<void> _addPlaylist() async {
    String? newPlaylistName = await _showAddPlaylistDialog();
    if (newPlaylistName != null && newPlaylistName.isNotEmpty) {
      User? user = _auth.currentUser;
      if (user != null) {
        DatabaseReference ref = _database.ref('bookshelf/${user.uid}');
        DatabaseReference newPlaylistRef = ref.push(); // Gera um ID único
        // ignore: unused_local_variable
        String playlistId = newPlaylistRef.key!;

        await newPlaylistRef.set({
          'name': newPlaylistName,
        });

        _loadPlaylists(); // Recarrega as playlists
      }
    }
  }

  // Exibe o diálogo para adicionar uma nova playlist
  Future<String?> _showAddPlaylistDialog() async {
    String? playlistName;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Playlist'),
          content: TextField(
            onChanged: (value) {
              playlistName = value;
            },
            decoration: const InputDecoration(hintText: 'Enter playlist name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (playlistName != null && playlistName?.isNotEmpty == true) {
                  Navigator.of(context)
                      .pop(playlistName); // Retorna o nome da playlist
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // Mostra o diálogo de confirmação de exclusão se não for a playlist "Favorites"
  void _showDeleteDialog(String playlistId, String playlistName) {
    if (playlistName != "Favorites") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Playlist'),
            content: Text('Are you sure you want to delete $playlistName?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                  _deletePlaylist(playlistId); // Chama função de deletar
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Favorites playlist cannot be deleted."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
