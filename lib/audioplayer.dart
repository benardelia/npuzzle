import 'package:audioplayers/audioplayers.dart';

class Player {
  Player({
    required this.src,
  });
  final String src;
  final audioPlayer = AudioPlayer();

  load() {
    
  }

  play() {
    audioPlayer.play(AssetSource('congratilations.wav'));
  }
}
