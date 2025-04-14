import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_controller.dart';
import '../models/song.dart';
class SongItem extends StatefulWidget {
  final Song song;
  final VoidCallback? onTap;

  const SongItem({super.key, required this.song, this.onTap});

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Hero(
              tag: 'albumArt-${widget.song.title}',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(widget.song.albumArtUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.song.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.song.artist,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Obx(() {
              final playerController = Get.find<PlayerController>();
              return IconButton(
                icon: Icon(
                  playerController.likedSongs.contains(widget.song)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: playerController.likedSongs.contains(widget.song) ? Colors.red : null,
                ),
                onPressed: () => playerController.toggleLike(widget.song),
              );
            }),
          ],
        ),
      )
    );
  }
}