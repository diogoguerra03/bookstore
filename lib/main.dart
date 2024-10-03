import 'package:flutter/material.dart';
import 'screens/auth/login.dart';
import 'screens/home_page.dart'; // Certifique-se de importar a página inicial
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Necessário para garantir que a inicialização do Flutter está concluída

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username =
      prefs.getString('username'); // Verifica se o username está armazenado

  runApp(MyApp(
      isLoggedIn: username != null)); // Passa o estado de login para o MyApp
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
