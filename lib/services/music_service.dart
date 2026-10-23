
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/song.dart';

class MusicService {
  Future<List<Song>> requestSongs(String term) async {
    final uri = Uri.https('itunes.apple.com', '/search', {
      'term': term,
      'entity': 'song',
      'limit': '25',
    });

    final response =
        await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'Server mengembalikan kode ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    return results
        .whereType<Map<String, dynamic>>()
        .map(Song.fromJson)
        .where((song) => song.id != 0)
        .toList();
  }
}
