import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  test('Movie.fromTmdbJson extracts data correctly', () {
    final mockJson = {
      'id': 299536,
      'title': 'Avengers: Infinity War',
      'release_date': '2018-04-25',
      'runtime': 149,
      'genres': [
        {'id': 12, 'name': 'Adventure'},
        {'id': 28, 'name': 'Action'},
        {'id': 878, 'name': 'Science Fiction'}
      ],
      'overview': 'As the Avengers and their allies...',
      'poster_path': '/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg',
      'vote_average': 8.245,
      'vote_count': 33200,
      'credits': {
        'crew': [
          {'job': 'Producer', 'name': 'Kevin Feige'},
          {'job': 'Director', 'name': 'Joe Russo'},
          {'job': 'Director', 'name': 'Anthony Russo'}
        ]
      }
    };

    final movie = Movie.fromTmdbJson(mockJson);

    expect(movie.id, 299536);
    expect(movie.title, 'Avengers: Infinity War');
    expect(movie.year, '2018-04-25');
    expect(movie.runtime, 149);
    expect(movie.genre, 'Adventure, Action, Science Fiction');
    expect(movie.director, 'Joe Russo');
    expect(movie.synopsis, 'As the Avengers and their allies...');
    expect(movie.posterUrl,
        'https://image.tmdb.org/t/p/w500/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg');
    expect(movie.rating, 8.245);
    expect(movie.voteCount, 33200);
  });

  test('Movie toMap and fromMap roundtrip', () {
    final movie = Movie(
      id: 557,
      title: 'Spider-Man',
      year: '2002-05-01',
      runtime: 121,
      genre: 'Action',
      director: 'Sam Raimi',
      synopsis: 'After being bitten by a spider...',
      posterUrl: 'https://image.tmdb.org/t/p/w500/spider.jpg',
      rating: 7.3,
      voteCount: 18908,
    );

    final map = movie.toMap();
    final fromMap = Movie.fromMap(map);

    expect(fromMap.id, movie.id);
    expect(fromMap.title, movie.title);
    expect(fromMap.year, movie.year);
    expect(fromMap.runtime, movie.runtime);
    expect(fromMap.genre, movie.genre);
    expect(fromMap.director, movie.director);
    expect(fromMap.synopsis, movie.synopsis);
    expect(fromMap.posterUrl, movie.posterUrl);
    expect(fromMap.rating, movie.rating);
    expect(fromMap.voteCount, movie.voteCount);
  });

  test('DatabaseHelper insert, retrieve and delete movie', () async {
    final movie = Movie(
      id: 9999,
      title: 'Test Movie',
      year: '2024-01-01',
      runtime: 120,
      genre: 'Comedy',
      director: 'Test Director',
      synopsis: 'Test synopsis',
      posterUrl: 'https://image.tmdb.org/t/p/w500/test.jpg',
      rating: 9.0,
      voteCount: 100,
    );

    await DatabaseHelper.instance.insertOrUpdateMovie(movie);
    final history = await DatabaseHelper.instance.getHistory();
    expect(history.any((m) => m.id == 9999), isTrue);

    await DatabaseHelper.instance.deleteMovie(9999);
    final historyAfterDelete = await DatabaseHelper.instance.getHistory();
    expect(historyAfterDelete.any((m) => m.id == 9999), isFalse);
  });
}
