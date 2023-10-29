// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicModel _$MusicModelFromJson(Map<String, dynamic> json) => MusicModel(
      list: (json['list'] as List<dynamic>?)
              ?.map((e) => MusicItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      allPage: json['allPage'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      source: json['source'] as String? ?? '',
    );

Map<String, dynamic> _$MusicModelToJson(MusicModel instance) =>
    <String, dynamic>{
      'list': instance.list,
      'allPage': instance.allPage,
      'total': instance.total,
      'source': instance.source,
    };

MusicItem _$MusicItemFromJson(Map<String, dynamic> json) => MusicItem(
      singer: json['singer'] as String? ?? '',
      name: json['name'] as String? ?? '',
      albumName: json['albumName'] as String? ?? '',
      albumId: json['albumId'] as String? ?? '',
      songmid: json['songmid'] as String? ?? '',
      source: json['source'] as String? ?? '',
      interval: json['interval'] as String? ?? '',
      img: json['img'] as String? ?? '',
      lrc: json['lrc'] as String? ?? '',
      otherSource: json['otherSource'] as String? ?? '',
      hash: json['hash'] as String? ?? '',
      qualityList: json['qualityList'] as List<dynamic>? ?? [],
      qualityMap: json['qualityMap'] as Map<String, dynamic>? ?? {},
      urlMap: json['urlMap'] as Map<String, dynamic>? ?? {},
      copyrightId: json['copyrightId'] as String? ?? '',
      lrcUrl: json['lrcUrl'] as String? ?? '',
      mrcUrl: json['mrcUrl'] as String? ?? '',
      trcUrl: json['trcUrl'] as String? ?? '',
    );

Map<String, dynamic> _$MusicItemToJson(MusicItem instance) => <String, dynamic>{
      'singer': instance.singer,
      'name': instance.name,
      'albumName': instance.albumName,
      'albumId': instance.albumId,
      'songmid': instance.songmid,
      'source': instance.source,
      'interval': instance.interval,
      'img': instance.img,
      'lrc': instance.lrc,
      'otherSource': instance.otherSource,
      'hash': instance.hash,
      'qualityList': instance.qualityList,
      'qualityMap': instance.qualityMap,
      'urlMap': instance.urlMap,
      'copyrightId': instance.copyrightId,
      'lrcUrl': instance.lrcUrl,
      'mrcUrl': instance.mrcUrl,
      'trcUrl': instance.trcUrl,
    };

MusicListModel _$MusicListModelFromJson(Map<String, dynamic> json) =>
    MusicListModel(
      list: (json['list'] as List<dynamic>?)
              ?.map((e) => MusicListItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      limit: json['limit'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      source: json['source'] as String? ?? '',
      page: json['page'] as int? ?? 0,
    );

Map<String, dynamic> _$MusicListModelToJson(MusicListModel instance) =>
    <String, dynamic>{
      'list': instance.list,
      'limit': instance.limit,
      'total': instance.total,
      'source': instance.source,
      'page': instance.page,
    };

MusicListItem _$MusicListItemFromJson(Map<String, dynamic> json) =>
    MusicListItem(
      name: json['name'] as String? ?? '',
      source: json['source'] as String? ?? '',
      img: json['img'] as String? ?? '',
      playCount: json['playCount'] as String? ?? '0',
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? '',
      time: json['time'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      total: json['total'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
    );

Map<String, dynamic> _$MusicListItemToJson(MusicListItem instance) =>
    <String, dynamic>{
      'playCount': instance.playCount,
      'id': instance.id,
      'name': instance.name,
      'author': instance.author,
      'time': instance.time,
      'img': instance.img,
      'grade': instance.grade,
      'total': instance.total,
      'desc': instance.desc,
      'source': instance.source,
    };
