import 'package:json_annotation/json_annotation.dart';
import 'package:lx_music_flutter/app/repository/song_repository.dart';

part 'music_item.g.dart';

@JsonSerializable()
class MusicItem {
  @JsonKey(name: 'id', defaultValue: '')
  final String id;

  @JsonKey(name: 'songName', defaultValue: '')
  final String songName;

  @JsonKey(name: 'artist', defaultValue: '')
  final String artist;

  @JsonKey(name: 'album', defaultValue: '')
  final String album;

  @JsonKey(name: 'hash', defaultValue: '')
  final String hash;

  @JsonKey(name: 'artistid', defaultValue: '')
  final String artistid;

  /// 歌曲长度
  @JsonKey(defaultValue: 0)
  final int length;

  /// 歌曲文件大小
  @JsonKey(defaultValue: 0)
  final int size;

  MusicItem({
    this.id = '',
    this.songName = '',
    this.artist = '',
    this.album = '',
    this.hash = '',
    this.artistid = '',
    this.length = 0,
    this.size = 0,
    this.url = '',
  });

  factory MusicItem.fromJson(Map<String, dynamic> json) => _$MusicItemFromJson(json);

  Map<String, dynamic> toJson() => _$MusicItemToJson(this);

  String? url;

  Future<String?> getUrl() async {
    // url ??= await SongRepository.getSongUrl(hash);
    return url;
  }
}

class Board {
  final String id;
  final String name;
  final String bangid;
  String? webId;

  Board({required this.id, required this.name, required this.bangid, this.webId});
}

/// 音乐信息
@JsonSerializable()
class MusicInfo {

  /// 歌手名称
  @JsonKey(name: 'singer', defaultValue: '')
  final String singer;

  @JsonKey(name: 'name', defaultValue: '')
  final String name;

  /// 专辑名称
  @JsonKey(name: 'albumName', defaultValue: '')
  final String albumName;

  @JsonKey(name: 'songmid', defaultValue: '')
  final String songmid;

  /// 来源 @AppUtil.sourceXX
  @JsonKey(name: 'source', defaultValue: '')
  final String source;

  /// 歌曲长度
  @JsonKey(name: 'interval', defaultValue: '')
  final String interval;

  @JsonKey(name: 'img', defaultValue: '')
  final String img;

  /// 歌词
  @JsonKey(name: 'lrc', defaultValue: '')
  String lrc;

  @JsonKey(name: 'otherSource', defaultValue: '')
  final String otherSource;

  /// 音乐格式类型 [{'128k':''},{'320k': ''}, {'flac': ''}]
  @JsonKey(name: 'types', defaultValue: [])
  final List types;

  /// 音乐格式类型 使用Map {'128k': '', '320k': '', 'flac': ''}
  @JsonKey(name: '_types', defaultValue: {})
  final Map typesMap;

  /// 对应格式类型的歌曲url地址 {'128k': 'http://xxxxxxx'}
  @JsonKey(name: 'typeUrl', defaultValue: {})
  Map typeUrl;

  MusicInfo({
    this.singer = '',
    this.name = '',
    this.albumName = '',
    this.songmid = '',
    this.source = '',
    this.interval = '',
    this.img = '',
    this.lrc = '',
    this.otherSource = '',
    this.types = const [],
    this.typesMap = const {},
    this.typeUrl = const {},
  });

  factory MusicInfo.fromJson(Map<String, dynamic> json) => _$MusicInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MusicInfoToJson(this);
}
