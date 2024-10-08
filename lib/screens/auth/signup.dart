import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../home_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart'; // Para obter o diretório temporário

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _password = '';
  // ignore: unused_field
  String _confirmPassword = '';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<File> loadAssetFile(String path) async {
    // Obtém o diretório temporário
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/favorites.png');

    // Carrega o arquivo da pasta assets
    final byteData = await rootBundle.load(path);

    // Escreve os bytes no arquivo
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'BookStore XPTO',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Campo de E-mail
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo de Username
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _username = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo de Password
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo de Confirm Password
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    onChanged: (value) {
                      setState(() {
                        _confirmPassword = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _password) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Botão de Sign Up
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          try {
                            // Tenta criar o utilizador no Firebase Auth
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .createUserWithEmailAndPassword(
                              email: _email,
                              password: _password,
                            );

                            String uid = userCredential
                                .user!.uid; // Obtém o UID do usuário

                            // Adiciona o utilizador ao Firebase Realtime Database
                            await FirebaseDatabase.instance
                                .ref('users/$uid')
                                .set({
                              'username': _username,
                              'email': _email,
                            });

                            // Gera um ID único para a playlist
                            DatabaseReference playlistRef = FirebaseDatabase
                                .instance
                                .ref('bookshelf/$uid')
                                .push(); // Gera o ID único

                            String playlistId =
                                playlistRef.key!; // Obtém o ID gerado

                            // Cria a playlist "Favorites" com o ID gerado
                            await playlistRef.set({
                              'name': 'Favorites',
                            });

                            // Faz o upload da imagem da prateleira 'favorites' para o Firebase Storage
                            try {
                              // Carrega o arquivo das assets
                              File file = await loadAssetFile(
                                  'assets/images/favorites.png');

                              // Faz o upload do arquivo para o Firebase Storage
                              // Faz o upload da imagem da playlist "Favorites" para o Firebase Storage
                              await FirebaseStorage.instance
                                  .ref(
                                      'bookshelf/$uid/$playlistId') // Usando o ID da playlist
                                  .putFile(file);

// Obtém a URL da imagem
                              String downloadUrl = await FirebaseStorage
                                  .instance
                                  .ref(
                                      'bookshelf/$uid/$playlistId') // Usando o ID da playlist
                                  .getDownloadURL();

// Atualiza a URL da imagem na Realtime Database
                              await playlistRef.update({
                                'image': downloadUrl,
                              });
                            } catch (e) {
                              Logger().e('Error uploading image: $e');
                            }

                            // Armazena o username e email no SharedPreferences
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString('uid', uid);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User created successfully!'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );

                              // Navega para a Home Page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      e.message ?? 'Failed to create user'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Link para se registar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Volta à página de login
                        },
                        child: const Text('Sign in'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
