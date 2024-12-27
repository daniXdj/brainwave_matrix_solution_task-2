class Article {
  final Source? source;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;

  Article({
    this.source,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: json['source'] != null ? Source.fromJson(json['source']) : null,
      author: json['author'] ?? 'Unknown Author',
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? 'No description available',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      content: json['content'] ?? 'No content available',
    );
  }
}

class NEWSAPI {
  final String status;
  final List<Source> sources;

  NEWSAPI({required this.status, required this.sources});

  factory NEWSAPI.fromJson(Map<String, dynamic> json) {
    return NEWSAPI(
      status: json['status'] ?? 'unknown',
      sources: (json['sources'] as List<dynamic>?)
              ?.map((source) => Source.fromJson(source))
              .toList() ??
          [],
    );
  }
}

class Source {
  final String id;
  final String name;
  final String description;
  final String url;
  final String? category;
  final String? language;
  final String? country;

  Source({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    this.category,
    this.language,
    this.country,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Source',
      description: json['description'] ?? 'No description available',
      url: json['url'] ?? '',
      category: json['category'],
      language: json['language'],
      country: json['country'],
    );
  }
}
