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

MusicInfo _$MusicInfoFromJson(Map<String, dynamic> json) => MusicInfo(
      singer: json['singer'] as String? ?? '',
      name: json['name'] as String? ?? '',
      albumName: json['albumName'] as String? ?? '',
      songmid: json['songmid'] as String? ?? '',
      source: json['source'] as String? ?? '',
      interval: json['interval'] as String? ?? '',
      img: json['img'] as String? ?? '',
      lrc: json['lrc'] as String? ?? '',
      otherSource: json['otherSource'] as String? ?? '',
      types: json['types'] as List<dynamic>? ?? [],
      typesMap: json['_types'] as Map<String, dynamic>? ?? {},
      typeUrl: json['typeUrl'] as Map<String, dynamic>? ?? {},
    );

Map<String, dynamic> _$MusicInfoToJson(MusicInfo instance) => <String, dynamic>{
      'singer': instance.singer,
      'name': instance.name,
      'albumName': instance.albumName,
      'songmid': instance.songmid,
      'source': instance.source,
      'interval': instance.interval,
      'img': instance.img,
      'lrc': instance.lrc,
      'otherSource': instance.otherSource,
      'types': instance.types,
      '_types': instance.typesMap,
      'typeUrl': instance.typeUrl,
    };
