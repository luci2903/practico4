class Movie {
  final int id;
  final String title;
  final String year;
  final int runtime;
  final String genre;
  final String director;
  final String synopsis;
  final String posterUrl;
  final double rating;
  final int voteCount;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.runtime,
    required this.genre,
    required this.director,
    required this.synopsis,
    required this.posterUrl,
    required this.rating,
    required this.voteCount,
  });

  factory Movie.fromTmdbJson(Map<String, dynamic> json) {
    String directorName = 'Desconocido';
    final credits = json['credits'];
    if (credits != null && credits['crew'] != null) {
      final crewList = credits['crew'] as List<dynamic>;
      for (final member in crewList) {
        if (member is Map<String, dynamic> && member['job'] == 'Director') {
          directorName = member['name'] ?? 'Desconocido';
          break;
        }
      }
    }

    String genresString = 'Sin género';
    if (json['genres'] != null) {
      final genresList = json['genres'] as List<dynamic>;
      final names = genresList
          .map((g) => g['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      if (names.isNotEmpty) {
        genresString = names.join(', ');
      }
    }

    String poster = '';
    final posterPath = json['poster_path'];
    if (posterPath != null && posterPath.toString().isNotEmpty) {
      poster = 'https://image.tmdb.org/t/p/w500$posterPath';
    }

    final releaseDate = json['release_date']?.toString() ??
        json['first_air_date']?.toString() ??
        'N/A';

    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Sin título',
      year: releaseDate,
      runtime: json['runtime'] as int? ?? 0,
      genre: genresString,
      director: directorName,
      synopsis: json['overview']?.toString() ?? 'Sin sinopsis disponible.',
      posterUrl: poster,
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'runtime': runtime,
      'genre': genre,
      'director': director,
      'synopsis': synopsis,
      'poster_url': posterUrl,
      'rating': rating,
      'vote_count': voteCount,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as int,
      title: map['title'] as String? ?? 'Sin título',
      year: map['year'] as String? ?? 'N/A',
      runtime: map['runtime'] as int? ?? 0,
      genre: map['genre'] as String? ?? '',
      director: map['director'] as String? ?? 'Desconocido',
      synopsis: map['synopsis'] as String? ?? '',
      posterUrl: map['poster_url'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      voteCount: (map['vote_count'] as num?)?.toInt() ?? 0,
    );
  }
}
