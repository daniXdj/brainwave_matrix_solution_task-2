import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'model/model.dart'; // Assuming you have an Article model in this file.
import 'package:url_launcher/url_launcher.dart';

Future<List<Article>> fetchArticleBySource(String source) async {
  final response = await http.get(Uri.parse(
      'https://newsapi.org/v2/top-headlines?sources=$source&apiKey=52e2b32c99364a0fae7358d522798f8a'));

  if (response.statusCode == 200) {
    List articles = json.decode(response.body)['articles'];
    return articles.map((article) => Article.fromJson(article)).toList();
  } else {
    throw Exception('Failed to load articles: ${response.reasonPhrase}');
  }
}

class ArticleScreen extends StatefulWidget {
  final Source source;
  const ArticleScreen({super.key, required this.source});

  @override
  State<StatefulWidget> createState() => ArticleScreenState();
}

class ArticleScreenState extends State<ArticleScreen> {
  late Future<List<Article>> listArticles;
  final refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    listArticles = fetchArticleBySource(widget.source.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.source.name),
      ),
      body: Center(
        child: RefreshIndicator(
          key: refreshKey,
          onRefresh: refreshListArticle,
          child: FutureBuilder<List<Article>>(
            future: listArticles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final articles = snapshot.data!;
                if (articles.isEmpty) {
                  return const Text('No articles found');
                }

                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return GestureDetector(
                      onTap: () {
                        if (article.url != null && article.url!.isNotEmpty) {
                          _launchUrl(article.url!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('URL not available')),
                          );
                        }
                      },
                      child: Card(
                        elevation: 1.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8.0),
                              width: 100.0,
                              height: 100.0,
                              child: (article.urlToImage != null &&
                                      article.urlToImage!.isNotEmpty)
                                  ? Image.network(article.urlToImage!,
                                      fit: BoxFit.cover, errorBuilder:
                                          (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image,
                                          size: 100);
                                    })
                                  : const Icon(Icons.image, size: 100),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article.title ?? 'No Title Available',
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      article.description ??
                                          'No description available',
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Published: ${article.publishedAt ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 11.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const Text('Unexpected error occurred');
            },
          ),
        ),
      ),
    );
  }

  Future<void> refreshListArticle() async {
    refreshKey.currentState?.show(atTop: false);
    setState(() {
      listArticles = fetchArticleBySource(widget.source.id);
    });
  }

void _launchUrl(String? url) async {
  
  if (url != null && await canLaunch(url)) {
    await launch(url);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Could not launch $url'),
    ));
  }
}

} 

