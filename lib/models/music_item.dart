import 'package:json_annotation/json_annotation.dart';
import 'package:lx_music_flutter/models/leader_board_model.dart';
import 'package:lx_music_flutter/models/song_list.dart';

part 'music_item.g.dart';

class Board {
  final String id;
  final String name;
  final String bangid;
  String? webId;

  Board({required this.id, required this.name, required this.bangid, this.webId});
}

/// 歌曲模型
@JsonSerializable()
class MusicModel {
  /// 歌曲列表
  @JsonKey(name: 'list', defaultValue: [])
  List<MusicItem> list;

  @JsonKey(name: 'allPage', defaultValue: 0)
  // 总页数
  int? allPage;
  @JsonKey(name: 'total', defaultValue: 0)
  // 总数
  int total;
  @JsonKey(name: 'source', defaultValue: '')
  // 来源 @see AppConst.sourceXX
  String source;

  int? page;
  int? limit;

  /// 歌单详情
  @JsonKey(name: 'info')
  DetailInfo? info;

  MusicModel({
    required this.list,
    this.allPage,
    required this.total,
    required this.source,
    this.page,
    this.info,
    this.limit,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) => _$MusicModelFromJson(json);

  Map<String, dynamic> toJson() => _$MusicModelToJson(this);

  factory MusicModel.empty() => MusicModel(list: [], total: 0, source: '');
}

@JsonSerializable()
class MusicItem {
  /// 歌手名
  @JsonKey(name: 'singer', defaultValue: '')
  String singer;

  /// 歌曲名
  @JsonKey(name: 'name', defaultValue: '')
  String name;

  /// 专辑名
  @JsonKey(name: 'albumName', defaultValue: '')
  String albumName;

  /// 专辑ID
  @JsonKey(name: 'albumId', defaultValue: '')
  String albumId;

  /// 歌曲id
  @JsonKey(name: 'songmid', defaultValue: '')
  String songmid;

  /// 歌曲来源
  @JsonKey(name: 'source', defaultValue: '')
  String source;

  /// 时长 展示格式化的时间 @see AppUtil.formatPlayTime
  @JsonKey(name: 'interval', defaultValue: '')
  String interval;

  /// 封面
  @JsonKey(name: 'img', defaultValue: '')
  String img;

  /// 歌词
  @JsonKey(name: 'lrc', defaultValue: '')
  String? lrc;

  @JsonKey(name: 'otherSource', defaultValue: '')
  String? otherSource;

  @JsonKey(name: 'hash', defaultValue: '')
  String? hash;

  /// 音质  [{'type': '128k', 'size': '3.2M'},{'type': '320k', 'size': '7.9M'}, {'type': 'flac', 'size': '15.2M'}]
  @JsonKey(name: 'qualityList', defaultValue: [])
  List qualityList;

  /// 音质映射集合 {'128k': {'size': '', 'hash': ''},}
  @JsonKey(name: 'qualityMap', defaultValue: {})
  Map qualityMap;

  /// 不同音质对应的歌曲实际链接地址
  @JsonKey(name: 'urlMap', defaultValue: {})
  Map urlMap;

  @JsonKey(name: 'copyrightId', defaultValue: '')
  String? copyrightId;

  @JsonKey(name: 'lrcUrl', defaultValue: '')
  String? lrcUrl;

  @JsonKey(name: 'mrcUrl', defaultValue: '')
  String? mrcUrl;

  @JsonKey(name: 'trcUrl', defaultValue: '')
  String? trcUrl;

  MusicItem({
    required this.singer,
    required this.name,
    required this.albumName,
    required this.albumId,
    required this.songmid,
    required this.source,
    required this.interval,
    required this.img,
    this.lrc,
    this.otherSource,
    this.hash,
    required this.qualityList,
    required this.qualityMap,
    required this.urlMap,
    this.copyrightId,
    this.lrcUrl,
    this.mrcUrl,
    this.trcUrl,
  });

  factory MusicItem.fromJson(Map<String, dynamic> json) => _$MusicItemFromJson(json);

  factory MusicItem.fromLeaderBoardItem(LeaderBoardItem item) {
    return MusicItem(
      singer: item.singer,
      name: item.name,
      albumName: item.albumName,
      albumId: item.albumId,
      songmid: item.songmid,
      source: item.source,
      interval: item.interval,
      img: item.img,
      qualityList: item.qualityList,
      qualityMap: item.qualityMap,
      urlMap: item.urlMap,
    );
  }

  Map<String, dynamic> toJson() => _$MusicItemToJson(this);
}

/// 歌单数据模型
@JsonSerializable()
class MusicListModel {
  /// 歌曲列表
  @JsonKey(name: 'list', defaultValue: [])
  List<MusicListItem> list;

  @JsonKey(name: 'limit', defaultValue: 0)
  int limit;

  @JsonKey(name: 'total', defaultValue: 0)
  int total;

  @JsonKey(name: 'source', defaultValue: '')
  String source;

  @JsonKey(name: 'page', defaultValue: 0)
  int? page;

  MusicListModel({
    required this.list,
    required this.limit,
    required this.total,
    required this.source,
    this.page,
  });

  factory MusicListModel.empty() => MusicListModel(list: [], limit: 0, total: 0, source: '');

  factory MusicListModel.fromJson(Map<String, dynamic> json) => _$MusicListModelFromJson(json);

  Map<String, dynamic> toJson() => _$MusicListModelToJson(this);
}

@JsonSerializable()
class MusicListItem {
  /// 播放次数
  @JsonKey(name: 'playCount', defaultValue: '0')
  String playCount;

  @JsonKey(name: 'id', defaultValue: '')
  String id;

  /// 歌曲名
  @JsonKey(name: 'name', defaultValue: '')
  String name;

  /// 作者
  @JsonKey(name: 'author', defaultValue: '')
  String author;

  @JsonKey(name: 'time', defaultValue: '')
  String? time;

  /// 封面
  @JsonKey(name: 'img', defaultValue: '')
  String img;

  @JsonKey(name: 'grade', defaultValue: '')
  String? grade;

  @JsonKey(name: 'total', defaultValue: '')
  String? total;

  /// 歌单描述
  @JsonKey(name: 'desc', defaultValue: '')
  String? desc;

  @JsonKey(name: 'source', defaultValue: '')
  String? source;

  MusicListItem({
    required this.name,
    required this.source,
    required this.img,
    required this.playCount,
    required this.id,
    required this.author,
    this.time,
    this.grade,
    this.total,
    this.desc,
  });

  factory MusicListItem.fromJson(Map<String, dynamic> json) => _$MusicListItemFromJson(json);

  Map<String, dynamic> toJson() => _$MusicListItemToJson(this);
}
