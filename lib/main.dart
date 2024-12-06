import 'package:flutter/material.dart';
import 'screens/auth/login.dart';
import 'screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/connection_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Necessário para garantir que a inicialização do Flutter está concluída

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('uid'); // Verifica se o uid está armazenado

  final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());

  // Verifica se o utilizador está online, se não, mete o estado de online a falso
  bool isOnline = connectivityResult.contains(ConnectivityResult.mobile) ||
      connectivityResult.contains(ConnectivityResult.wifi);

  runApp(MyApp(
    isLoggedIn: uid != null, // Verifica se o utilizador está logado
    isOnline: isOnline, // Verifica se o utilizador está online
  ));
}

class MyApp extends StatelessWidget {
  final bool
      isLoggedIn; // Adiciona uma propriedade para verificar se o utilizador está logado
  final bool
      isOnline; // Adiciona uma propriedade para verificar se o utilizador está online

  const MyApp({super.key, required this.isLoggedIn, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookstore XPTO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isOnline
          ? isLoggedIn
              ? const HomePage()
              : const LoginPage()
          : const NoConnectionPage(),
    );
  }
}
