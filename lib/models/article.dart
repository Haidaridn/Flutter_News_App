class Article {
  const Article({
    required this.title,
    this.sourceName,
    this.author,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.category,
  });

  final String title;
  final String? sourceName;
  final String? author;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final String? category;

  /// `fromJson` mengubah satu objek JSON NewsAPI menjadi model Article.
  factory Article.fromJson(Map<String, dynamic> json) {
    final title = _readNullableString(json['title']);
    if (title == null) {
      throw const FormatException('Judul artikel wajib diisi.');
    }

    final source = json['source'];
    final sourceName = source is Map<String, dynamic>
        ? _readNullableString(source['name'])
        : null;

    return Article(
      title: title,
      sourceName: sourceName,
      author: _readNullableString(json['author']),
      description: _readNullableString(json['description']),
      url: _readNullableString(json['url']),
      urlToImage: _readNullableString(json['urlToImage']),
      publishedAt: _readNullableDate(json['publishedAt']),
      content: _readNullableString(json['content']),
      category: _readNullableString(json['category']),
    );
  }

  static String? _readNullableString(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  static DateTime? _readNullableDate(Object? value) {
    final dateText = _readNullableString(value);
    return dateText == null ? null : DateTime.tryParse(dateText);
  }
}
