

import 'package:lx_music_flutter/models/song_list.dart';

class KGSongList {
  static List<SortItem> sortList = [
    SortItem(name: '推荐', tid: 'recommend', id: '5', isSelect: true),
    SortItem(name: '最热', tid: 'hot', id: '6'),
    SortItem(name: '最新', tid: 'new', id: '7'),
    SortItem(name: '热藏', tid: 'hot_collect', id: '3'),
    SortItem(name: '飙升', tid: 'rise', id: '8'),
  ];
}