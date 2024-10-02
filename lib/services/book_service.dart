import 'dart:convert'; // Para manipulação de JSON
import 'package:http/http.dart' as http; // Para fazer requisições HTTP
import '../models/book_model.dart'; // Certifica-te que o modelo Book está corretamente definido

class BookService {
  // Função para buscar livros com base numa query personalizada e com paginação
  Future<List<Book>> fetchBooks(String query, int page) async {
    // Define a URL da API, incluindo a query e paginação
    final String apiUrl =
        "https://openlibrary.org/search.json?$query&page=$page&limit=20";

    // Faz a requisição à API
    final response = await http.get(Uri.parse(apiUrl));

    // Verifica o código de resposta
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // Verifica se a chave 'docs' existe na resposta
      if (jsonResponse.containsKey('docs')) {
        List booksJson = jsonResponse['docs'];
        // Mapeia os dados JSON para a lista de objetos Book
        return booksJson.map((data) => Book.fromJson(data)).toList();
      } else {
        // Lança uma exceção se o formato da resposta não for o esperado
        throw Exception('Unexpected format: "docs" key not found');
      }
    } else {
      // Lança uma exceção com o código de status caso a requisição falhe
      throw Exception(
          'Failed to load books with status code: ${response.statusCode}');
    }
  }
}
