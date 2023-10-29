// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leader_board_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderBoardModel _$LeaderBoardModelFromJson(Map<String, dynamic> json) =>
    LeaderBoardModel(
      list: (json['list'] as List<dynamic>?)
              ?.map((e) => LeaderBoardItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      source: json['source'] as String? ?? '',
      page: json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );

Map<String, dynamic> _$LeaderBoardModelToJson(LeaderBoardModel instance) =>
    <String, dynamic>{
      'list': instance.list,
      'total': instance.total,
      'source': instance.source,
      'page': instance.page,
      'limit': instance.limit,
    };

LeaderBoardItem _$LeaderBoardItemFromJson(Map<String, dynamic> json) =>
    LeaderBoardItem(
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
      qualityList: json['qualityList'] as List<dynamic>? ?? [],
      qualityMap: json['qualityMap'] as Map<String, dynamic>? ?? {},
      urlMap: json['urlMap'] as Map<String, dynamic>? ?? {},
      lrcUrl: json['lrcUrl'] as String? ?? '',
      mrcUrl: json['mrcUrl'] as String? ?? '',
      trcUrl: json['trcUrl'] as String? ?? '',
    );

Map<String, dynamic> _$LeaderBoardItemToJson(LeaderBoardItem instance) =>
    <String, dynamic>{
      'singer': instance.singer,
      'name': instance.name,
      'albumName': instance.albumName,
      'albumId': instance.albumId,
      'songmid': instance.songmid,
      'source': instance.source,
      'interval': instance.interval,
      'img': instance.img,
      'lrc': instance.lrc,
      'lrcUrl': instance.lrcUrl,
      'mrcUrl': instance.mrcUrl,
      'trcUrl': instance.trcUrl,
      'otherSource': instance.otherSource,
      'qualityList': instance.qualityList,
      'qualityMap': instance.qualityMap,
      'urlMap': instance.urlMap,
    };
