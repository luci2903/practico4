import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String apiKey = '2dca580c2a14b55200e784d157207b4d';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  static Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    final isYear = RegExp(r'^\d{4}$').hasMatch(cleanQuery);
    final Uri url;

    if (isYear) {
      url = Uri.parse(
          '$baseUrl/discover/movie?api_key=$apiKey&primary_release_year=$cleanQuery&sort_by=popularity.desc');
    } else {
      url = Uri.parse(
          '$baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(cleanQuery)}&include_adult=false');
    }

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> results = data['results'] ?? [];
      return results.map((item) {
        return {
          'id': item['id'] as int? ?? 0,
          'title': item['title']?.toString() ?? 'Sin título',
          'release_date': item['release_date']?.toString() ?? 'N/A',
          'poster_path': item['poster_path']?.toString() ?? '',
          'vote_average': (item['vote_average'] as num?)?.toDouble() ?? 0.0,
        };
      }).toList();
    } else {
      throw Exception('Error al conectar con la API de TMDB');
    }
  }

  static Future<Movie> getMovieDetails(int id) async {
    final url = Uri.parse(
        '$baseUrl/movie/$id?api_key=$apiKey&append_to_response=credits');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Movie.fromTmdbJson(data);
    } else {
      final tvUrl = Uri.parse(
          '$baseUrl/tv/$id?api_key=$apiKey&append_to_response=credits');
      final tvResponse = await http.get(tvUrl);
      if (tvResponse.statusCode == 200) {
        final Map<String, dynamic> tvData = jsonDecode(tvResponse.body);
        return Movie.fromTmdbJson(tvData);
      }
      throw Exception('No se pudo obtener el detalle de la película');
    }
  }
}
