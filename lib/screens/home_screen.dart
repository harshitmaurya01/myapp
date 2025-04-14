import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/player_controller.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/screens/playlist_screen.dart';
import 'package:myapp/widgets/mini_player.dart';
import 'package:myapp/widgets/song_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final PlayerController playerController = Get.find<PlayerController>();
  final TextEditingController _searchController = TextEditingController();
  List<Song> filteredSongs = [];

  @override
  void initState() {
    super.initState();
    filteredSongs = playerController.songs;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      filteredSongs = playerController.songs.where((song) {
        return song.title.toLowerCase().contains(query) ||
            song.artist.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by title or artist',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Song Categories
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategory('Recently Played', playerController.songs.reversed.toList()),
                  _buildCategory('Trending', playerController.songs),
                  _buildCategory('Liked', playerController.songs.where((s) => s.isLiked?.value ?? false).toList()),
                  _buildCategory('Recently Added', playerController.songs),
                ],
              ),
            ),
          ),

          // Mini Player
          Obx(() {
            final currentSong = playerController.currentSong?.value;
            // Return the proper widget based on currentSong
            return currentSong != null ? MiniPlayer() : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<Song> songs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // List View
        SizedBox(
          height: title == 'Recently Played' ? 150 : null,
          child: (title == 'Recently Played')
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                // Fixed null safety issue with coverUrl
                                song.coverUrl ?? 'https://placeholder.com/100', 
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    return SongItem(song: songs[index]);
                  },
                ),
        ),
      ],
    );
  }
}