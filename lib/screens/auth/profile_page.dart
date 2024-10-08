import 'package:bookstore/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'edit_profile_page.dart'; // A nova página para editar o perfil
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../library_page.dart'; // A página Library

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = 'user@example.com'; // Placeholder para o email
  String uid = '';
  String avatarUrl = ''; // URL da imagem do avatar
  int playlistCount = 0; // Contador de playlists
  int bookCount = 0; // Contador de livros únicos

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPlaylistStatistics();
  }

  // Função para carregar o UID e os dados do usuário
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString('uid') ?? ''; // Carrega o UID do SharedPreferences
      email = FirebaseAuth.instance.currentUser?.email ?? '';
    });

    // Adiciona um listener para atualizações em tempo real
    if (uid.isNotEmpty) {
      DatabaseReference ref = FirebaseDatabase.instance.ref('users/$uid');
      ref.onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null) {
          Map<String, dynamic> userData =
              Map<String, dynamic>.from(data as Map<dynamic, dynamic>);
          setState(() {
            username =
                userData['username'] ?? 'Unknown User'; // Atualiza o username
            avatarUrl = userData['avatarUrl'] ?? ''; // Atualiza a URL do avatar
          });
        }
      });
    }
  }

  // Função para carregar as estatísticas das playlists e livros
  void _loadPlaylistStatistics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid') ?? ''; // Carrega o UID do SharedPreferences

    if (uid.isNotEmpty) {
      DatabaseReference ref = FirebaseDatabase.instance.ref('bookshelf/$uid');
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

        // Verificar o conteúdo das playlists
        Logger().i("Playlists carregadas: $values");

        // Atualiza o contador de playlists
        setState(() {
          playlistCount = values.keys.length;
        });

        // Contar livros únicos em todas as playlists
        Set<String> uniqueBooks = {};
        values.forEach((key, value) {
          if (value is Map && value.containsKey('books')) {
            Map<dynamic, dynamic> books =
                value['books'] as Map<dynamic, dynamic>;
            uniqueBooks.addAll(books.keys.cast<String>());
          }
        });

        // Atualiza o contador de livros com o tamanho do conjunto de livros únicos
        setState(() {
          bookCount = uniqueBooks.length;
        });
      } else {
        setState(() {
          playlistCount = 0; // Define para 0 caso não encontre playlists
        });
      }
    }
  }

  // Função para fazer logout
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid'); // Remove o UID do SharedPreferences

    if (!mounted) return;
    // Navega de volta para a página de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Função para exibir o pop-up de confirmação de logout
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                _logout(); // Chama a função de logout
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed:
                _showLogoutConfirmationDialog, // Muda para o pop-up de confirmação
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 75,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl) // Exibe a imagem do avatar
                  : null, // Avatar padrão
              child: avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 50) // Ícone padrão
                  : null,
            ),
            const SizedBox(height: 20),
            Text(username,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(email,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            const Divider(
              color: Colors.grey,
              height: 2,
            ),
            const SizedBox(height: 20),
            _buildStatistics(), // Chama a função que exibe as estatísticas
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            // Navegação para a página Home
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          } else if (index == 1) {
            // Navegação para a página Library
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LibraryPage(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatistics() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _StatisticCard(
                title: 'Playlists',
                count: playlistCount.toString(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatisticCard(
                title: 'Saved Books',
                count: bookCount.toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String title;
  final String count;

  const _StatisticCard({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(count,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
