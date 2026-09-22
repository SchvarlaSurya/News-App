class NewsArticle {
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final String? author;
  final Source? source;

  NewsArticle({
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.author,
    this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      content: json['content'],
      author: json['author'],
      source: json['source'] != null ? Source.fromJson(json['source']) : null,
    );
  }

  /// Dipakai untuk menyimpan bookmark ke shared_preferences.
  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'url': url,
    'urlToImage': urlToImage,
    'publishedAt': publishedAt,
    'content': content,
    'author': author,
    'source': source?.toJson(),
  };

  bool get hasImage => urlToImage != null && urlToImage!.isNotEmpty;

  String get sourceName => source?.name ?? 'Sumber tidak diketahui';

  /// Waktu terbit dalam zona waktu perangkat, null kalau datanya tidak terbaca.
  DateTime? get publishedDate {
    if (publishedAt == null || publishedAt!.isEmpty) return null;
    final parsed = DateTime.tryParse(publishedAt!)?.toLocal();
    if (parsed == null) return null;
    // Jam server bisa sedikit mendahului jam perangkat; jangan sampai
    // tampil "dalam 2 menit".
    final now = DateTime.now();
    return parsed.isAfter(now) ? now : parsed;
  }

  /// Isi artikel tanpa potongan "[+1234 chars]" bawaan NewsAPI.
  String? get readableContent {
    final raw = (content != null && content!.isNotEmpty)
        ? content
        : description;
    if (raw == null || raw.isEmpty) return null;
    return raw.replaceAll(RegExp(r'\s*\[\+\d+ chars\]$'), '').trim();
  }

  /// NewsAPI menandai artikel yang sudah ditarik dengan judul "[Removed]".
  bool get isUsable =>
      url != null && url!.isNotEmpty && title != null && title != '[Removed]';
}

class Source {
  final String? id;
  final String? name;

  Source({this.id, this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
