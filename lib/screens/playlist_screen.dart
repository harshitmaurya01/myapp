import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/player_controller.dart';
import '../models/song.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find();
    return Obx(() {
      final likedSongs =
          playerController.songs.where((song) => song.isLiked!.value).toList();
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
        ),
        body: likedSongs.isEmpty
            ? const Center(
                child: Text(
                  'No songs liked yet!',
                ),
              )
            : ListView.builder(
                itemCount: likedSongs.length,
                itemBuilder: (context, index) {
                  final song = likedSongs[index];
                  return Dismissible(
                    key: Key(song.title),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      playerController.toggleLike(song);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: ListTile(
                      leading: Hero(
                        tag: 'albumArt-${song.title}',
                        child: Image.network(song.albumArtUrl,
                            width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      title: Text(song.title),
                      subtitle: Text(song.artist),
                      trailing: IconButton(
                        icon: Icon(
                          song.isLiked!.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              song.isLiked!.value ? Colors.red : null,
                        ),
                        onPressed: () => playerController.toggleLike(song),
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }
}

// Fixed extension - now returns a proper boolean value instead of null
extension BoolValue on Widget {
  bool get value => true; // Default return value changed from null to true
}

class Playlist {
  final String name;
  final List<Song> songs; // Added generic type to List
  
  Playlist({required this.name, required this.songs});
}