import 'dart:convert'; // Para manipulação de JSON
import 'package:http/http.dart' as http; // Para fazer requisições HTTP
import '../models/book_model.dart'; // Modelo dos livros

class BookService {
  final String apiKey = "AIzaSyDFKIn1VLkrLA90_pivMJlpdylD5flt0Fw";

  // Função para buscar livros com base numa query personalizada e com paginação
  Future<List<Book>> fetchBooks(String query, int page) async {
    const int maxResults = 20; // Número máximo de resultados por página
    final String apiUrl =
        "https://www.googleapis.com/books/v1/volumes?q=$query&startIndex=${(page - 1) * maxResults}&maxResults=$maxResults&key=$apiKey";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('items')) {
        List booksJson = jsonResponse['items'];
        return booksJson.map((data) => Book.fromJson(data)).toList();
      } else {
        throw Exception('Unexpected format: "items" key not found');
      }
    } else {
      throw Exception(
          'Failed to load books with status code: ${response.statusCode}');
    }
  }

  // Função para buscar detalhes do livro com base no ID
  Future<Book> fetchBookDetails(String bookId) async {
    final String apiUrl =
        "https://www.googleapis.com/books/v1/volumes/$bookId?key=$apiKey";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Book.fromJson(jsonResponse); // Mapeia para o modelo BookDetails
    } else {
      throw Exception('Failed to load book details');
    }
  }
}
