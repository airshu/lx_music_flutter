/// 全局常量
class AppConst {

  static String version = '1.1.0';

  /// 设置面板内嵌导航器的key
  static const int navigatorKeySetting = 10000;

  static const int navigatorKeyKW = 10001;

  static const String bHh = '624868746c';

  Map<String, dynamic> headers = {
    'User-Agent': 'lx-music request',
    AppConst.bHh: AppConst.bHh,
  };

  static const String nameKW = '小蜗音乐';
  static const String nameKG = '小枸音乐';
  static const String nameWY = '小芸音乐';
  static const String nameMG = '小蜜音乐';
  static const String nameQQ = '小秋音乐';

  static const List platformNames = [
    nameKW,
    nameKG,
    nameWY,
    nameMG,
    nameQQ,
  ];
}

/// 所有url
class Urls {
  static String getBaseUrl() {
    return '';
  }

  /// 酷狗搜索
  static const String kugouSearch = "http://mobilecdn.kugou.com/new/app/i/search.php?";

  /// 获取真实播放地址
  static const String kugouGetSongUrl = "http://trackercdn.kugou.com/i/?";
}
