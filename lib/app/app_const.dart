/// 全局常量
class AppConst {
  /// 设置面板内嵌导航器的key
  static const int navigatorKeySetting = 10000;

  static const int navigatorKeyKW = 10001;
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
