import 'package:audio_service/audio_service.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => LxAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.lx_music_flutter.audio',
      androidNotificationChannelName: 'LX Audio Service',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class LxAudioHandler extends BaseAudioHandler {

}
