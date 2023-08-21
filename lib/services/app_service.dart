import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lx_music_flutter/app/sql/music_sql_manager.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/download_manager/dio_download_manager.dart';
import 'package:lx_music_flutter/utils/download_manager/download_manager.dart';
import 'package:lx_music_flutter/utils/encrypt_util.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';
import 'package:lx_music_flutter/utils/player/music_player.dart';

///
class AppService extends GetxService {
  static AppService get to => Get.find();

  late String iv;
  late String presetKey;
  late String linuxapiKey;

  String publicKey = '-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB\n-----END PUBLIC KEY-----';
  late String eapiKey;

  @override
  void onInit() async {
    super.onInit();

    /// 设置日志等级
    Logger.setLevel(Logger.levelDebug);

    // 设置默认下载器
    DownloadManager.instance = DioDownloadManager();

    iv = EncryptUtil.encodeBase64('0102030405060708');
    presetKey = EncryptUtil.encodeBase64('0CoJUm6Qyw8W8jud');
    linuxapiKey = EncryptUtil.encodeBase64('rFgB&h#%2?^eDg:Q');
    eapiKey = EncryptUtil.encodeBase64('e82ckenh8dichen8');


    // 初始化本地数据
    List<MusicItem> list = await MusicSQLManager().getAllMusicItems();
    for (var item in list) {
      String? url = await item.getUrl();
      Logger.debug('init local data: $url');
      MusicPlayer().playList.add(AudioSource.uri(Uri.parse(url!)));
    }

    // 初始化播放器
    MusicPlayer().init();
  }

  void exitApp() {

  }

  void logout() {

  }


}
