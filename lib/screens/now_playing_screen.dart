import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/player_controller.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final PlayerController playerController = Get.find<PlayerController>();
  bool _isShuffled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final song = playerController.currentSong?.value;
      final isPlaying = playerController.isPlaying;
      final currentPosition = playerController.currentPosition.value;

      if (song == null) {
        return const Scaffold(
          body: Center(child: Text('No song playing')),
        );
      }

      return Scaffold(
        body: Stack(
          children: [
            Hero(
              tag: 'album-art-${song.title}',
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(song.coverUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  child: Container(
                    color: Colors.black.withAlpha((0.5 * 255).round()),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'album-art-${song.title}',
                      child: RotationTransition(
                        turns: _controller,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.4 * 255).round()),
                                spreadRadius: 5,
                                blurRadius: 10,
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(song.coverUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      song.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      song.artist,
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      value: currentPosition.inSeconds.toDouble(),
                      min: 0,
                      max: song.duration.toDouble(),
                      onChanged: (value) {
                        playerController
                            .updatePosition(Duration(seconds: value.toInt()));
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isShuffled ? Icons.shuffle_on : Icons.shuffle,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isShuffled = !_isShuffled;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white, size: 30),
                          onPressed: () => playerController.playPrevious(),
                        ),
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: Colors.white,
                            size: 50,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              playerController.pauseSong();
                              _controller.stop();
                            } else {
                              playerController.playSong(song); // Pass the song
                              _controller.repeat();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next,
                              color: Colors.white, size: 30),
                          onPressed: () => playerController.playNext(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Details',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Plays: ${song.plays}',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      'Likes: ${song.likes}',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      'Duration: ${song.duration} seconds',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
