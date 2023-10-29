

import 'package:json_annotation/json_annotation.dart';

part 'leader_board_model.g.dart';

@JsonSerializable()
class LeaderBoardModel {
  /// 歌曲列表
  @JsonKey(name: 'list', defaultValue: [])
  List<LeaderBoardItem> list;

  @JsonKey(name: 'total', defaultValue: 0)
  int total;

  @JsonKey(name: 'source', defaultValue: '')
  String source;

  @JsonKey(name: 'page', defaultValue: 0)
  int? page;

  @JsonKey(name: 'limit', defaultValue: 0)
  int limit;

  LeaderBoardModel({
    required this.list,
    required this.total,
    required this.source,
    this.page,
    required this.limit,
  });

  factory LeaderBoardModel.empty() => LeaderBoardModel(list: [], total: 0, source: '', limit: 0);

  factory LeaderBoardModel.fromJson(Map<String, dynamic> json) => _$LeaderBoardModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderBoardModelToJson(this);
}


@JsonSerializable()
class LeaderBoardItem {

  @JsonKey(name: 'singer', defaultValue: '')
  String singer;

  @JsonKey(name: 'name', defaultValue: '')
  String name;

  @JsonKey(name: 'albumName', defaultValue: '')
  String albumName;

  @JsonKey(name: 'albumId', defaultValue: '')
  String albumId;

  @JsonKey(name: 'songmid', defaultValue: '')
  String songmid;

  @JsonKey(name: 'source', defaultValue: '')
  String source;

  @JsonKey(name: 'interval', defaultValue: '')
  String interval;

  @JsonKey(name: 'img', defaultValue: '')
  String img;

  @JsonKey(name: 'lrc', defaultValue: '')
  String? lrc;

  @JsonKey(name: 'lrcUrl', defaultValue: '')
  String? lrcUrl;
  @JsonKey(name: 'mrcUrl', defaultValue: '')
  String? mrcUrl;
  @JsonKey(name: 'trcUrl', defaultValue: '')
  String? trcUrl;

  @JsonKey(name: 'otherSource', defaultValue: '')
  String? otherSource;

  @JsonKey(name: 'qualityList', defaultValue: [])
  List qualityList;

  /// 音质映射集合 {'128k': {'size': '', 'hash': ''},}
  @JsonKey(name: 'qualityMap', defaultValue: {})
  Map qualityMap;

  /// 不同音质对应的歌曲实际链接地址
  @JsonKey(name: 'urlMap', defaultValue: {})
  Map urlMap;


  LeaderBoardItem({
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
    required this.qualityList,
    required this.qualityMap,
    required this.urlMap,
    this.lrcUrl,
    this.mrcUrl,
    this.trcUrl,
  });

  factory LeaderBoardItem.fromJson(Map<String, dynamic> json) => _$LeaderBoardItemFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderBoardItemToJson(this);


}