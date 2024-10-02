import 'dart:convert'; // Para manipulação de JSON
import 'package:http/http.dart' as http; // Para fazer requisições HTTP
import '../models/book_model.dart'; // Modelo dos livros

class BookService {
  // Função para buscar livros com base numa query personalizada e com paginação
  Future<List<Book>> fetchBooks(String query, int page) async {
    final String apiUrl =
        "https://openlibrary.org/search.json?$query&page=$page&limit=20";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('docs')) {
        List booksJson = jsonResponse['docs'];
        return booksJson.map((data) => Book.fromJson(data)).toList();
      } else {
        throw Exception('Unexpected format: "docs" key not found');
      }
    } else {
      throw Exception(
          'Failed to load books with status code: ${response.statusCode}');
    }
  }

  // Função para buscar detalhes do livro com base no workId
  Future<Book> fetchBookDetails(String workId) async {
    final String apiUrl = "https://openlibrary.org$workId.json";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Book.fromJson(jsonResponse); // Mapeia para o modelo BookDetails
    } else {
      throw Exception('Failed to load book details');
    }
  }
}
