import 'package:shared_preferences/shared_preferences.dart';

class Settings {

  Settings._() {
    init();
  }

  factory Settings() => _instance;
  static final Settings _instance = Settings._();



  bool startupAutoPlay = false; // 启动自动播放
  String musicSource = MusicSource.httpSourceDirect; // 音乐来源



  Future<void> init() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    startupAutoPlay = sharedPreferences.getBool('startupAutoPlay') ?? false;
    musicSource = sharedPreferences.getString('musicSource') ?? MusicSource.httpSourceDirect;
  }

  Future<void> refresh() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('startupAutoPlay', startupAutoPlay);
    sharedPreferences.setString('musicSource', musicSource);
  }

  Future reset() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    init();
  }
}

/// 音乐来源
class MusicSource {
  static const String httpSourceDirect = 'direct';
  static const String httpSourceTemp = 'temp';
  static const String httpSourceTest = 'test';

  static const List httpSourceList = [
    httpSourceDirect,
    // httpSourceTemp,
    // httpSourceTest,
  ];
}
