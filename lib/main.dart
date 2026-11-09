import 'package:flutter/material.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/screens/home_screen.dart';
import 'package:news_app/services/mock_news_service.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  const NewsService newsService = MockNewsService();
  runApp(const MyApp(newsService: newsService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.newsService});

  final NewsService newsService;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Provider dibuat di akar aplikasi agar status berita tersedia di Beranda.
      create: (_) => NewsProvider(newsService: newsService)..loadArticles(),
      child: MaterialApp(
        title: 'News App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
