import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Para manipulação de arquivos

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _avatarUrl = ''; // URL da imagem do avatar
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmNewPassword = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carregar dados do usuário
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid =
        prefs.getString('uid'); // Recupera o UID do Shared Preferences

    if (uid != null) {
      // Busca os dados do usuário na Realtime Database
      DatabaseReference ref = FirebaseDatabase.instance.ref('users/$uid');
      final snapshot = await ref.once();

      if (snapshot.snapshot.value != null) {
        setState(() {
          _username = snapshot.snapshot.child('username').value.toString();
          _avatarUrl = snapshot.snapshot.child('avatarUrl').value.toString() ??
              ''; // Carregar a URL do avatar se disponível
          _isLoading = false;
        });
      }
    }
  }

  // Função para atualizar os dados do usuário
  void _updateUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;

    // Atualiza o username se alterado
    if (_username.length > 3 && _username != prefs.getString('username')) {
      await FirebaseDatabase.instance.ref('users/${user!.uid}').update({
        'username': _username,
      });
      await prefs.setString('username', _username);
    }

    // Verifica se o usuário quer alterar a senha
    if (_currentPassword.isNotEmpty ||
        _newPassword.isNotEmpty ||
        _confirmNewPassword.isNotEmpty) {
      // Validação para senhas
      if (_newPassword.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New password must be at least 8 characters'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_newPassword != _confirmNewPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        // Reautentica o usuário com a senha atual
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: prefs.getString('email') ?? '',
          password: _currentPassword,
        );

        // Atualiza a senha no Firebase Auth
        await userCredential.user!.updatePassword(_newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context); // Volta para a página anterior
  }

  // Função para selecionar a imagem do perfil
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Carrega a imagem para o Firebase Storage
      try {
        await FirebaseStorage.instance
            .ref('userProfilePictures/$uid')
            .putFile(imageFile);

        // Obtém a URL da imagem
        String downloadUrl = await FirebaseStorage.instance
            .ref('userProfilePictures/$uid')
            .getDownloadURL();

        setState(() {
          _avatarUrl = downloadUrl; // Atualiza a URL do avatar
        });

        // Opcionalmente, você pode armazenar a URL na Realtime Database
        await FirebaseDatabase.instance.ref('users/$uid').update({
          'avatarUrl': _avatarUrl,
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed:
                _updateUserData, // Chama a função para atualizar os dados do usuário
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
                  GestureDetector(
                    onTap: _pickImage, // Torna o CircleAvatar clicável
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _avatarUrl.isNotEmpty
                          ? NetworkImage(_avatarUrl) // Exibe a imagem do avatar
                          : const AssetImage(
                                  'assets/images/avatar_placeholder.png')
                              as ImageProvider<Object>,
                      child: _avatarUrl.isEmpty
                          ? const Icon(Icons.person,
                              size: 60) // Exibe o ícone padrão
                          : null,
                    ),
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
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      _currentPassword = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      _newPassword = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      _confirmNewPassword = value;
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
