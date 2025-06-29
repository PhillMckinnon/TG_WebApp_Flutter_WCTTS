import 'package:audioplayers/audioplayers.dart';

final player = AudioPlayer();

Future<void> playAlertSound_Good() async {
  await player.play(UrlSource('/assets/sounds/synth.mp3'));  
}
Future<void> playAlertSound_Bad() async {
  await player.play(AssetSource('/assets/sounds/fail.mp3'));  
}