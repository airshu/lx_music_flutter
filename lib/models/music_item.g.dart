// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicItem _$MusicItemFromJson(Map<String, dynamic> json) => MusicItem(
      id: json['id'] as String? ?? '',
      songName: json['songName'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      album: json['album'] as String? ?? '',
      hash: json['hash'] as String? ?? '',
      artistid: json['artistid'] as String? ?? '',
      length: json['length'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      url: json['url'] as String? ?? '',
    );

Map<String, dynamic> _$MusicItemToJson(MusicItem instance) => <String, dynamic>{
      'id': instance.id,
      'songName': instance.songName,
      'artist': instance.artist,
      'album': instance.album,
      'hash': instance.hash,
      'artistid': instance.artistid,
      'length': instance.length,
      'size': instance.size,
      'url': instance.url,
    };
