import 'dart:math' as math;

class AppUtil {

  static String sizeFormate(dynamic size) {
    if(size is String) {
      size = num.parse(size);
    }
    if(size == 0) {
      return '0B';
    }
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

  static String formatPlayCount(dynamic num) {
    if(num is String) {
      num = int.parse(num);
    }
    if (num > 100000000) {
      return '${(num / 10000000).truncateToDouble() / 10}亿';
    }
    if (num > 10000) {
      return '${(num / 1000).truncateToDouble() / 10}万';
    }
    return num.toString();
  }

  static String dateFormat(String _date, [String format = 'Y-M-D h:m:s']) {

    var date = toDateObj(_date);
    if(date == null) {
      return '';
    }
    return format.replaceAllMapped(RegExp(r'Y+|M+|D+|h+|m+|s+'), (match) {
      String? str = match.group(0);
      if(str == null) {
        return '';
      }
      switch (str) {
        case 'Y':
          return date.year.toString();
        case 'M':
          return numFix(date.month + 1);
        case 'D':
          return numFix(date.day);
        case 'h':
          return numFix(date.hour);
        case 'm':
          return numFix(date.minute);
        case 's':
          return numFix(date.second);
        default:
          return '';
      }
    });
  }

  static toDateObj(dynamic date) {
    if(date is DateTime) {
      return date;
    }
    if(date is String) {
      if(date.contains('T')) {
        date = date.split('.')[0].replaceAll('-', '/');
      } else {
        date = DateTime.parse(date);
      }
    }
    if(date is num) {
      date = DateTime.fromMillisecondsSinceEpoch(date.toInt());
    }
    return date;
  }

  static String formatSinger(String rawData) {
    return rawData.replaceAll('&', '、');
  }


}