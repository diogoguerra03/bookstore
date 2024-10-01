import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:logger/logger.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 80), // Espaçamento superior
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza o Row
              children: [
                // Campo de texto para pesquisa
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        hintText: 'Filter by name, genre, etc...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Ícone de pesquisa
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Ação de pesquisa
                      Logger().i('Search button pressed');
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
              height:
                  40), // Espaçamento entre a barra de pesquisa e o restante conteúdo

          // Conteúdo adicional da página
          const Center(
            child: Text(
              'Main content of Home Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // O índice da página atual (Home)
        onTap: (index) {
          // Navegação com base no índice
          if (index == 0) {
            // Já está na Home
          } else if (index == 1) {
            Logger().i('Library');
          } else if (index == 2) {
            Logger().i('Profile');
          }
        },
      ),
    );
  }
}
