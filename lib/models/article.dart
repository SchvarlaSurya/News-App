class Article {
  final String title;
  final String? description;
  final String? content;
  final String? urlToImage;
  final String url;
  final DateTime publishedAt;
  final String sourceName;

  Article({
    required this.title,
    this.description,
    this.content,
    this.urlToImage,
    required this.url,
    required this.publishedAt,
    required this.sourceName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Tanpa judul',
      description: json['description'],
      content: json['content'],
      urlToImage: json['urlToImage'],
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt']) ?? DateTime.now()
          : DateTime.now(),
      sourceName: json['source'] != null
          ? (json['source']['name'] ?? 'Tidak diketahui')
          : 'Tidak diketahui',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'urlToImage': urlToImage,
      'url': url,
      'publishedAt': publishedAt.toIso8601String(),
      'source': {'name': sourceName},
    };
  }
}