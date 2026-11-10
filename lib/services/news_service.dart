import 'package:news_app/models/article.dart';

abstract class NewsService {
  /// Future memberikan daftar artikel setelah proses asinkron selesai.
  Future<List<Article>> fetchArticles({String? query, String? category});
}
