import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Para manipulação de arquivos
import 'package:logger/logger.dart'; // Para logs

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _avatarUrl = ''; // URL da imagem do avatar
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmNewPassword = '';
  bool _isLoading = true;
  bool _obscureCurrentPassword = true; // Para mostrar/ocultar a senha atual
  bool _obscureNewPassword = true; // Para mostrar/ocultar a nova senha
  bool _obscureConfirmPassword =
      true; // Para mostrar/ocultar a confirmação da senha
  File? _imageFile; // Armazenar o arquivo da imagem selecionada

  String? _usernameErrors; // Mensagem de erro para o campo de username
  String? _currentPasswordErrors; // Mensagem de erro para o campo de senha
  String? _newPasswordErrors; // Mensagem de erro para o campo de nova senha
  String?
      _confirmNewPasswordErrors; // Mensagem de erro para o campo de confirmação da nova senha

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

          // Aqui você verifica se a URL do avatar existe
          var avatarUrlValue = snapshot.snapshot.child('avatarUrl').value;
          _avatarUrl = avatarUrlValue != null
              ? avatarUrlValue.toString()
              : ''; // Carregar a URL do avatar se disponível
          _isLoading = false;
        });
      }
    }
  }

  // Função para atualizar os dados do usuário
  void _updateUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    // receber o username do snapshot
    DatabaseReference ref = FirebaseDatabase.instance.ref('users/${user!.uid}');
    final snapshot = await ref.once();
    String username = snapshot.snapshot.child('username').value.toString();

    // verifica se o username se foi alterado e se é válido (mínimo de 3 caracteres)
    if (username != _username && _username.length < 3) {
      setState(() {
        _usernameErrors = 'Username must be at least 3 characters';
      });
      return;
    }

    // Verifica se o usuário quer alterar a senha
    if (_currentPassword.isNotEmpty ||
        _newPassword.isNotEmpty ||
        _confirmNewPassword.isNotEmpty) {
      // Validação para senhas
      if (_newPassword.length < 8) {
        setState(() {
          _newPasswordErrors = 'New password must be at least 8 characters';
        });
        return;
      }
      if (_newPassword != _confirmNewPassword) {
        setState(() {
          _confirmNewPasswordErrors = 'Passwords do not match';
        });
        return;
      }

      try {
        // buscar o email do usuário
        String email = user.email!;
        // Reautentica o usuário com a senha atual
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: _currentPassword,
        );

        // Se a autenticação for bem-sucedida, atualiza a senha no Firebase Auth
        await userCredential.user!.updatePassword(_newPassword);
      } catch (e) {
        // Trata o erro de autenticação
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change password!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return; // Não prosseguir se a autenticação falhar
      }
    }

    await FirebaseDatabase.instance.ref('users/${user.uid}').update({
      'username': _username,
    });

    // Carrega a imagem para o Firebase Storage se uma imagem foi selecionada
    if (_imageFile != null) {
      String uid = user.uid;

      // Carrega a imagem para o Firebase Storage
      try {
        await FirebaseStorage.instance
            .ref('userProfilePictures/$uid')
            .putFile(_imageFile!);

        // Obtém a URL da imagem
        String downloadUrl = await FirebaseStorage.instance
            .ref('userProfilePictures/$uid')
            .getDownloadURL();

        // Atualiza a URL na Realtime Database
        await FirebaseDatabase.instance.ref('users/$uid').update({
          'avatarUrl': downloadUrl,
        });
      } catch (e) {
        Logger().e('Error uploading image: $e');
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context); // Volta para a página anterior
  }

  // Função para selecionar a imagem do perfil
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile =
            File(pickedFile.path); // Armazena o arquivo da imagem selecionada
        _avatarUrl = pickedFile
            .path; // Atualiza a URL do avatar para a imagem escolhida (local)
      });
    }
  }

  // Função para remover a imagem de perfil
  Future<void> _removeProfileImage() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    if (_avatarUrl.isNotEmpty) {
      // Remove a imagem do Firebase Storage
      await FirebaseStorage.instance.ref('userProfilePictures/$uid').delete();

      // Remove a URL da imagem no Realtime Database
      await FirebaseDatabase.instance.ref('users/$uid').update({
        'avatarUrl': null,
      });
    }

    setState(() {
      _avatarUrl = ''; // Limpa a URL do avatar
      _imageFile = null; // Limpa o arquivo da imagem
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile image removed successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          : SingleChildScrollView(
              // Adiciona SingleChildScrollView
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Exibe a imagem do usuário ou um avatar padrão
                    GestureDetector(
                      onTap: _pickImage, // Torna o CircleAvatar clicável
                      child: CircleAvatar(
                        radius: 75,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) // Exibe a imagem local
                            : _avatarUrl.isNotEmpty
                                ? NetworkImage(
                                    _avatarUrl) // Exibe a imagem do avatar
                                : null,
                        child: _avatarUrl.isEmpty && _imageFile == null
                            ? const Icon(Icons.person,
                                size: 60) // Exibe o ícone padrão
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Tap to change image',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    // Botão para remover a imagem de perfil
                    if (_avatarUrl.isNotEmpty ||
                        _imageFile !=
                            null) // Exibe o botão somente se houver uma imagem
                      SizedBox(
                        width: 150, // Largura do botão
                        child: ElevatedButton(
                          onPressed: _removeProfileImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Botão vermelho
                          ),
                          child: const Text('Remove Image',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: _username,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        prefixIcon:
                            const Icon(Icons.person), // Ícone de usuário
                        errorText: _usernameErrors,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _username = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // Campo para a senha atual
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        prefixIcon: const Icon(Icons.lock), // Ícone de cadeado
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                        ),
                        errorText: _currentPasswordErrors,
                      ),
                      obscureText: _obscureCurrentPassword,
                      onChanged: (value) {
                        _currentPassword = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Campo para a nova senha
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        prefixIcon: const Icon(Icons.lock), // Ícone de cadeado
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        errorText: _newPasswordErrors,
                      ),
                      obscureText: _obscureNewPassword,
                      onChanged: (value) {
                        _newPassword = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Campo para confirmar a nova senha
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        prefixIcon: const Icon(Icons.lock), // Ícone de cadeado
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        errorText: _confirmNewPasswordErrors,
                      ),
                      obscureText: _obscureConfirmPassword,
                      onChanged: (value) {
                        _confirmNewPassword = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
