import 'package:json_annotation/json_annotation.dart';
import 'package:lx_music_flutter/app/respository/song_repository.dart';

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
