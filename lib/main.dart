import 'package:flutter/material.dart';
import 'screens/auth/login.dart';
import 'screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Necessário para garantir que a inicialização do Flutter está concluída

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('uid'); // Verifica se o uid está armazenado

  runApp(
      MyApp(isLoggedIn: uid != null)); // Passa o estado de login para o MyApp
}

class MyApp extends StatelessWidget {
  final bool
      isLoggedIn; // Adiciona uma propriedade para verificar se o utilizador está logado

  const MyApp(
      {super.key, required this.isLoggedIn}); // Uso de super parâmetros e const

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookstore XPTO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn
          ? const HomePage()
          : const LoginPage(), // Redireciona conforme o estado de login
    );
  }
}
