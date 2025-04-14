import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/now_playing_screen.dart';
import '../controllers/player_controller.dart';

class MiniPlayer extends StatelessWidget {
  MiniPlayer({super.key});

  final PlayerController playerController = Get.find<PlayerController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = playerController.currentSong?.value;

      // If there's no current song, don't display the mini player
      if (currentSong == null) {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onTap: () {
          Get.to(() => NowPlayingScreen());
        },
        child: Container(
          height: 60,
          color: Theme.of(context).primaryColor.withAlpha(204),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Album Art
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  currentSong.coverUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),

              // Song Title
              Expanded(
                child: Text(
                  currentSong.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Play / Pause Button
              IconButton(
                icon: Icon(
                  playerController.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (playerController.isPlaying) {
                    playerController.pauseSong();
                  } else {
                    playerController.playSong(currentSong);
                  }
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
