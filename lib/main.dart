import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_reading_app/Article.dart';
import 'model/model.dart'; // Assuming you have a `Source` model in this file.

Future<List<Source>> fetchNews() async {
  final response = await http.get(Uri.parse(
      'https://newsapi.org/v2/top-headlines/sources?apiKey=52e2b32c99364a0fae7358d522798f8a'));

  if (response.statusCode == 200) {
    List sources = json.decode(response.body)['sources']; // Fixed key name.
    return sources.map((source) => Source.fromJson(source)).toList();
  } else {
    throw Exception('Failed to load news');
  }
}

void main() {
  runApp(NewsApp());
}

class NewsApp extends StatefulWidget {
  const NewsApp({super.key});

  @override
  State<StatefulWidget> createState() => NewsAppState();
}

class NewsAppState extends State<NewsApp> {
  var list_sources; // Declared as a Future.

  final refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    refreshListSource();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Reading',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Scaffold(
        appBar: AppBar(
          title: Text('News App'),
        ),
        body: Center(
          child: RefreshIndicator(
            key: refreshKey,
            onRefresh: refreshListSource,
            child: FutureBuilder<List<Source>>(
              future: list_sources, // Pass the future correctly.
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  List<Source> sources = snapshot.data!;
                  return ListView(
                    children: sources
                        .map(
                          (source) => GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ArticleScreen(source: source,)));
                            },
                            child: Card(
                              elevation: 1.0,
                              color: Colors.white,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 14.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2.0),
                                    width: 100.0,
                                    height: 130.0,
                                    color: Colors.grey[200], // Placeholder color.
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children:[ Expanded(
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  top: 20.0, bottom: 10.0),
                                              child: Text(
                                                source.name,
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          ]
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 20.0,bottom: 10.0),
                                          child: Text(source.description,style: TextStyle( color: Colors.grey,fontSize: 12.0,fontWeight: FontWeight.bold),),
                                        ),
                                         Container(
                                          margin: EdgeInsets.only(top: 10.0,bottom: 10.0),
                                          child: Text( 'Category: ${source.category}',style: TextStyle( color: Colors.black,fontSize: 14.0,fontWeight: FontWeight.bold),),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                }
                return CircularProgressIndicator(); // Show loading indicator by default.
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshListSource() async {
    refreshKey.currentState?.show(atTop: false);
    setState(() {
      list_sources = fetchNews(); // Assign the future correctly.
    });
  }
}
