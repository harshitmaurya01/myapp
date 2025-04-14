import 'package:flutter/material.dart';
import '../models/song.dart';

class SongSearchDelegate extends SearchDelegate<Song> {
  final List<Song> songs;

  SongSearchDelegate(this.songs);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Song(id: '', title: '', artist: '', album: '', albumArtUrl: ''));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Song> searchResults = songs
        .where((song) =>
            song.title.toLowerCase().contains(query.toLowerCase()) ||
            song.artist.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final song = searchResults[index];
        return ListTile(
          title: Text(song.title),
          subtitle: Text(song.artist),
          onTap: () {
            close(context, song);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Song> suggestionList = query.isEmpty
        ? []
        : songs
            .where((song) =>
                song.title.toLowerCase().contains(query.toLowerCase()) ||
                song.artist.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final song = suggestionList[index];
        return ListTile(
          title: Text(song.title),
          subtitle: Text(song.artist),
          onTap: () {
            query = song.title;
            close(context, song);
          },
        );
      },
    );
  }
}