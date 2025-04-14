import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/player_controller.dart';
import 'utils/dummy_data.dart';
import 'search_delegate.dart';
import 'models/song.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  await themeController.loadTheme();
  Get.put(themeController);
  runApp(const MusicApp());
}

class ThemeController extends GetxController {
  final _themeMode = Rx<ThemeMode>(ThemeMode.system);

  ThemeMode get themeMode => _themeMode.value;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme');
    if (themeString != null) {
      _themeMode.value = themeString == 'light' ? ThemeMode.light : ThemeMode.dark;
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newThemeMode =
        _themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _themeMode.value = newThemeMode;
    await prefs.setString(
        'theme', newThemeMode == ThemeMode.light ? 'light' : 'dark');
  }
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Music App',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        ),
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.grey[100],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      themeMode: Get.find<ThemeController>().themeMode,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlayerController controller = Get.put(PlayerController());
  late List<Song> songs;
  late final List<Song> recentlyPlayed;
  List<Song> get likedSongs => controller.likedSongs;
  Song? currentSong;
  bool isPlaying = false;

  void playSong(Song song) {
    setState(() {
      currentSong = song;
      isPlaying = true;
      if (!recentlyPlayed.contains(song)) {
        recentlyPlayed.add(song);
      }
    });
  } 

  void togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void toggleLike(Song song) {
    controller.toggleLike(song);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SongSearchDelegate(songs),
              );
            },
          ),
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.light
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: () => Get.find<ThemeController>().toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (recentlyPlayed.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentlyPlayed.length,
                itemBuilder: (context, index) {
                  return SongRecentlyPlayedCard(
                    song: recentlyPlayed[index], 
                    onTap: playSong
                  );
                },  
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                buildCategory("Trending", songs.sublist(0, 5)),
                buildCategory("Liked Songs", likedSongs),
                buildCategory("Recently Added", songs.sublist(5, 10)),
              ],
            ),
          ),
          if (currentSong != null)
            MiniPlayer(
              song: currentSong!,
              isPlaying: isPlaying,
              onTap: () => playSong(currentSong!),
              onTogglePlay: togglePlay,
            ),
        ],
      ),
    );
  }

  Widget buildCategory(String title, List<Song> songs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return SongItemCard(song: songs[index], onTap: playSong);
            },
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    songs = dummySongs;
    recentlyPlayed = [];
  }
}

class SongItemCard extends StatelessWidget {
  const SongItemCard({super.key, required this.song, required this.onTap});

  final Song song;
  final Function(Song) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(song),
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: song.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(song.albumArtUrl,
                    height: 120, width: 120, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(song.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(song.artist,
                style: TextStyle(color: Theme.of(context).iconTheme.color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class SongRecentlyPlayedCard extends StatelessWidget {
  const SongRecentlyPlayedCard({
    super.key, 
    required this.song, 
    required this.onTap
  });

  final Song song;
  final Function(Song) onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(song),
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Hero(  
              tag: song.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Image.network(song.albumArtUrl,  
                    height: 80, width: 80, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(song.title,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
      ),
      body: const Center(
        child: Text('Playlist Screen'),
      ),
    );
  }
}

class MiniPlayer extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onTogglePlay;

  const MiniPlayer({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(song.albumArtUrl,
                        height: 40, width: 40, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 8),
                  Text(song.title, overflow: TextOverflow.ellipsis),
                ],
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: onTogglePlay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}