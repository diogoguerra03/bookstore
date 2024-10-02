class Book {
  final String title;
  final String author;
  final int coverId;

  Book({
    required this.title,
    required this.author,
    required this.coverId,
  });

  // Função para transformar o JSON da API num objeto Book
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] as String,
      author: json['author_name'] != null && json['author_name'].isNotEmpty
          ? json['author_name'][0]
          : 'No author available',
      coverId: json['cover_i'] ?? 0, // Se não houver cover, usa 0 como padrão
    );
  }
}
