class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String publisher;
  final String publishedDate;
  final String description;
  final int pageCount;
  final List<String> categories;
  final double averageRating;
  final int ratingsCount;
  final String coverUrl;
  final String amount;
  final String currencyCode; // Moeda
  final String saleability; // Indica se o livro está à venda
  final String saleInfoUrl; // URL de venda

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.publisher,
    required this.publishedDate,
    required this.description,
    required this.pageCount,
    required this.categories,
    required this.averageRating,
    required this.ratingsCount,
    required this.coverUrl,
    this.amount = '0.0',
    this.currencyCode = 'EUR',
    this.saleability = 'NOT_FOR_SALE',
    this.saleInfoUrl = '',
  });

  // Função para transformar o JSON da API num objeto Book
  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];

    return Book(
        id: json['id'] as String,
        title: volumeInfo['title'] as String,
        authors: volumeInfo['authors'] != null
            ? List<String>.from(volumeInfo['authors'])
            : ['No authors available'],
        publisher: volumeInfo['publisher'] ?? 'No publisher available',
        publishedDate: volumeInfo['publishedDate'] ?? 'No date available',
        description: volumeInfo['description'] ?? 'No description available',
        pageCount: volumeInfo['pageCount'] ?? 0,
        categories: volumeInfo['categories'] != null
            ? List<String>.from(volumeInfo['categories'])
            : [],
        averageRating: volumeInfo['averageRating'] != null
            ? volumeInfo['averageRating'].toDouble()
            : 0.0,
        ratingsCount: volumeInfo['ratingsCount'] ?? 0,
        coverUrl: volumeInfo['imageLinks'] != null
            ? volumeInfo['imageLinks']['thumbnail']
            : '', // Fallback se não houver capa
        amount: json['saleInfo']['listPrice'] != null
            ? json['saleInfo']['listPrice']['amount'].toString()
            : 'Free',
        currencyCode: json['saleInfo']['listPrice'] != null &&
                json['saleInfo']['listPrice']['currencyCode'] != null
            ? json['saleInfo']['listPrice']['currencyCode']
            : 'EUR', // Moeda padrão é o Euro
        saleability: json['saleInfo']['saleability'] ?? 'NOT_FOR_SALE',
        saleInfoUrl: json['saleInfo']['buyLink'] ?? '');
  }
}
