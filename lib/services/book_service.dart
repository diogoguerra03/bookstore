import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart'; // Certifica-te de que o caminho está correto

class BookService {
  // Função para buscar livros com base em qualquer query personalizada
  Future<List<Book>> fetchBooks(String query) async {
    final String apiUrl =
        "https://openlibrary.org/search.json?$query"; // Query genérica

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List booksJson = jsonResponse['docs'];
      return booksJson.map((data) => Book.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }
}
