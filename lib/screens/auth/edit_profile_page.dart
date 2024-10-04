import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para autenticação
import 'change_pass_page.dart'; // Importar a página de alteração de senha

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _avatarUrl = ''; // URL da imagem do avatar
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carregar dados do usuário
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Unknown User';
      _email = FirebaseAuth.instance.currentUser?.email ??
          ''; // Carrega o email do Firebase Auth
      _avatarUrl =
          ''; // Aqui você pode implementar a lógica para carregar a imagem do avatar
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Aqui você pode implementar a lógica de salvar as alterações
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Exibe a imagem do usuário ou um avatar padrão
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _avatarUrl.isNotEmpty
                        ? NetworkImage(_avatarUrl) // Exibe a imagem do avatar
                        : null, // Se não houver URL, não defina uma imagem
                    child: _avatarUrl.isEmpty
                        ? const Icon(Icons.person,
                            size: 60) // Exibe o ícone padrão
                        : null, // Se houver URL, não exiba o ícone
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: _username,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    onChanged: (value) {
                      _username = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    onChanged: (value) {
                      _email = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, // Define a largura do botão
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage()),
                        );
                      }, // Defina a cor do texto aqui
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Change Password',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
