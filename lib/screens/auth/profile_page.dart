import 'package:bookstore/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'edit_profile_page.dart'; // A nova página para editar o perfil
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = 'user@example.com'; // Placeholder para o email
  String uid = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
          });
        }
      });
    }
  }

  // Função para fazer logout
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid'); // Remove o UID do SharedPreferences

    // Navega de volta para a página de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
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
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
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
            _buildStatistics(),
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
          }
        },
      ),
    );
  }

  Widget _buildStatistics() {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _StatisticCard(title: 'Playlists', count: '3')),
            SizedBox(width: 16),
            Expanded(child: _StatisticCard(title: 'Saved Books', count: '10')),
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
