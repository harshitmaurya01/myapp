// ignore: implementation_imports
import 'package:flutter/src/widgets/framework.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String albumArtUrl;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArtUrl,
  });
  static final empty = Song(
      id: '', title: '', artist: '', album: '', albumArtUrl: '');

  int? get duration => null;

  Widget? get isLiked => null;

  get value => null;

  String? get coverUrl => null;
}