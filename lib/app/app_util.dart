import 'dart:math' as math;

class AppUtil {

  static String sizeFormate(num size) {
    List units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var number = (math.log(size) / math.log(1024)).floor();
    return '${(size / math.pow(1024, number)).toStringAsFixed(2)}${units[number]}';
  }

  static String formatSingerName({singers, nameKey = 'name', join='、'}) {
    if(singers is List) {
      List singer = [];
      for (var item in singers) {
        String? name = item[nameKey];
        if(name == null) {
          continue;
        }
        singer.add(name);
      }
      return decodeName(singer.join(join));
    }
    return decodeName(singers);
  }

  static String decodeName(String? str) {
    final encodeNames = {
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&apos;': "'",
      '&#039;': "'",
      '&nbsp;': ' '
    };
    return str?.replaceAllMapped(RegExp(r'&(amp|lt|gt|quot|apos|#039|nbsp);'), (match) => encodeNames[match] ?? '') ?? '';
  }

  static String formatPlayTime(int time) {
    int m = (time / 60).truncate();
    int s = (time % 60).truncate();
    return m == 0 && s == 0 ? '--/--' : '${numFix(m)}:${numFix(s)}';
  }

  static String numFix(int num) {
    return num.toString().padLeft(2, '0');
  }
}