/// Sumber berita (object `source` di respons NewsAPI).
class Source {
  final String? id;
  final String name;

  const Source({this.id, required this.name});

  factory Source.fromJson(Map<String, dynamic>? json) {
    return Source(
      id: json?['id'],
      name: json?['name'] ?? 'Tidak diketahui',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

/// Satu artikel berita.
class NewsArticle {
  final Source source;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String? content;

  const NewsArticle({
    required this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
  });

  bool get hasImage => urlToImage != null && urlToImage!.isNotEmpty;

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      source: Source.fromJson(json['source'] as Map<String, dynamic>?),
      author: json['author'],
      title: json['title'] ?? 'Tanpa judul',
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.toJson(),
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt.toIso8601String(),
      'content': content,
    };
  }
}
