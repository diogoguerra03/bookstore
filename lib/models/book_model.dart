class Book {
  final String title;
  final String author;
  final int coverId;
  final String workId;
  final String description;
  final List<String> subjects;
  final int? wantToRead;
  final int? readingCount;
  final int? readCount;

  Book({
    required this.title,
    required this.author,
    required this.coverId,
    required this.workId,
    this.description = 'No description available',
    this.subjects = const [], // Inicializa como uma lista vazia
    this.wantToRead = 0,
    this.readingCount = 0,
    this.readCount = 0,
  });

  // Função para transformar o JSON da API num objeto Book
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] as String,
      author: json['author_name'] != null && json['author_name'].isNotEmpty
          ? json['author_name'][0]
          : 'No author available',
      coverId: json['cover_i'] ?? 0, // Se não houver cover, usa 0 como padrão
      workId: json['key'] as String,
      description: json['description'] ?? 'No description available',
      subjects: List<String>.from(
          json['subjects'] ?? []), // Adiciona a lista de subjects
      wantToRead: json['want_to_read_count'] ?? 0,
      readingCount: json['currently_reading_count'] ?? 0,
      readCount: json['already_read_count'] ?? 0,
    );
  }
}
