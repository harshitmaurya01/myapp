import 'package:get/get.dart';
import '../models/song.dart';

class PlayerController extends GetxController {
  final _songs = <Song>[].obs;
  final _currentSong = Rx<Song?>(null);
  final _isPlaying = false.obs;
  final _songPosition = 0.0.obs;
  final _duration = 0.obs;

  final likedSongs = <Song>[].obs;
  List<Song> get songs => _songs;
  Song? get currentSong => _currentSong.value;
  bool get isPlaying => _isPlaying.value;
  double get songPosition => _songPosition.value;
  int get duration => _duration.value;

  get currentPosition => null;

  set songs(List<Song> value) => _songs.value = value;

  void playSong(Song song) {
    _currentSong.value = song;
    _isPlaying.value = true;
    _songPosition.value = 0.0;
    update();
  }

  void pauseSong() {
    _isPlaying.value = false;
    update();
  }

  void playNext() {
    if (_currentSong.value == null) return;
    int currentIndex = _songs.indexOf(_currentSong.value!);
    if (currentIndex < _songs.length - 1) {
      // playSong(_songs[currentIndex + 1]);
    }
  }

  void playPrevious() {
    if (_currentSong.value == null) return;
    int currentIndex = _songs.indexOf(_currentSong.value!);
    if (currentIndex > 0) {
      // playSong(_songs[currentIndex - 1]);
    }
  }

  void toggleLike(Song song) {
    if (likedSongs.contains(song)) {
      likedSongs.remove(song);
    } else {
      likedSongs.add(song);
    }
  }

  void updateSongPosition(double position) {
    _songPosition.value = position;
  }

  void updatePosition(Duration duration) {}
}