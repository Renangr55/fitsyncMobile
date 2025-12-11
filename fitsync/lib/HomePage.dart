import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Modelo de Notícia
class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String publishedAt;
  final String sourceName;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.publishedAt,
    required this.sourceName,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'Sem título',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      sourceName: json['source']?['name'] ?? '',
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool loading = true;

  late Future<List<NewsArticle>> _futureNews;

  @override
  void initState() {
    super.initState();
    _futureNews = fetchHealthNews();
  }


  Future<List<NewsArticle>> fetchHealthNews() async {
    final url = Uri.parse('https://saurav.tech/NewsAPI/top-headlines/category/health/in.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = data['articles'] as List;
      return articles.map((json) => NewsArticle.fromJson(json)).toList();
    } else {
      throw Exception('Error to load news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F0F), Color(0xFF1C1C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              const Text(
                "Welcome to FitApp",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: CarouselSlider(
                    items: [
                      cardBanner("assets/image/firstBanner.jpg"),
                      cardBanner("assets/image/secondBanner.jpg"),
                    ],
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      viewportFraction: 0.85,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              
              const SizedBox(height: 10),

              

              const SizedBox(height: 20),

              const Text(
                "Health News",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              FutureBuilder<List<NewsArticle>>(
                future: _futureNews,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.greenAccent),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Nenhuma notícia encontrada.', style: TextStyle(color: Colors.white70));
                  }

                  final news = snapshot.data!;

                  return Column(
                    children: news.map((article) => cardNews(article)).toList(),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // Widgets
  // ---------------------------------------------------

  Widget cardBanner(String img) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(img, fit: BoxFit.cover, width: double.infinity),
      ),
    );
  }

  Widget cardExercicio(dynamic ex) {
    final descricao = (ex["descricao"]?.toString().trim().isNotEmpty == true)
        ? ex["descricao"]
        : "No description";

    final muscles = (ex["muscles"] as List<dynamic>?)
            ?.map((m) => m.toString())
            .join(" • ") ??
        "No muscles";

    return Card(
      color: const Color.fromARGB(50, 255, 255, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          ex["nome"] ?? "Exercício",
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              descricao,
              style: const TextStyle(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              muscles,
              style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
            ),
          ],
        ),
        trailing: const Icon(Icons.fitness_center, color: Colors.greenAccent),
      ),
    );
  }

  Widget cardNews(NewsArticle article) {
    return Card(
      color: const Color.fromARGB(50, 255, 255, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          article.title,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              article.description.isNotEmpty
                  ? article.description
                  : "Sem descrição",
              style: const TextStyle(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              'news source : ${article.sourceName}',
              style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
            ),
          ],
        ),
        trailing: article.imageUrl.isNotEmpty
            ? Image.network(
                article.imageUrl,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.broken_image, color: Colors.greenAccent),
              )
            : const Icon(Icons.article, color: Colors.greenAccent),
        onTap: () {
          if (article.url.isNotEmpty) {
            _launchURL(article.url);
          }
        },
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link')),
      );
    }
  }
}
