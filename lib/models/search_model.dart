import 'package:json_annotation/json_annotation.dart';

part 'search_model.g.dart';

/// 搜索页数据模型
@JsonSerializable()
class SearchMusicModel {
  /// 歌曲列表
  @JsonKey(name: 'list', defaultValue: [])
  List<SearchItem> list;

  @JsonKey(name: 'allPage', defaultValue: 0)
  // 总页数
  int allPage;
  @JsonKey(name: 'total', defaultValue: 0)
  // 总数
  int total;
  @JsonKey(name: 'source', defaultValue: '')
  // 来源 @see AppConst.sourceXX
  String source;

  SearchMusicModel({
    required this.list,
    required this.allPage,
    required this.total,
    required this.source,
  });

  factory SearchMusicModel.fromJson(Map<String, dynamic> json) => _$SearchMusicModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchMusicModelToJson(this);
}

@JsonSerializable()
class SearchItem {
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

  SearchItem({
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

  factory SearchItem.fromJson(Map<String, dynamic> json) => _$SearchItemFromJson(json);

  Map<String, dynamic> toJson() => _$SearchItemToJson(this);
}

/// 搜索歌单数据模型
@JsonSerializable()
class SearchListModel {
  /// 歌曲列表
  @JsonKey(name: 'list', defaultValue: [])
  List<SearchListItem> list;

  @JsonKey(name: 'limit', defaultValue: 0)
  int limit;

  @JsonKey(name: 'total', defaultValue: 0)
  int total;

  @JsonKey(name: 'source', defaultValue: '')
  String source;

  SearchListModel({
    required this.list,
    required this.limit,
    required this.total,
    required this.source,
  });

  factory SearchListModel.fromJson(Map<String, dynamic> json) => _$SearchListModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchListModelToJson(this);
}

@JsonSerializable()
class SearchListItem {
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
  String total;

  /// 歌单描述
  @JsonKey(name: 'desc', defaultValue: '')
  String? desc;

  @JsonKey(name: 'source', defaultValue: '')
  String? source;

  SearchListItem({
    required this.name,
    required this.source,
    required this.img,
    required this.playCount,
    required this.id,
    required this.author,
    this.time,
    this.grade,
    required this.total,
    this.desc,
  });

  factory SearchListItem.fromJson(Map<String, dynamic> json) => _$SearchListItemFromJson(json);

  Map<String, dynamic> toJson() => _$SearchListItemToJson(this);
}
