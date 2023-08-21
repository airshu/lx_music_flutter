// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicItem _$MusicItemFromJson(Map<String, dynamic> json) => MusicItem(
      json['id'] as String? ?? '',
      json['songName'] as String? ?? '',
      json['artist'] as String? ?? '',
      json['album'] as String? ?? '',
      json['hash'] as String? ?? '',
      json['artistid'] as String? ?? '',
      json['length'] as int? ?? 0,
      json['size'] as int? ?? 0,
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
    };
