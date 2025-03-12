// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailInfo _$DetailInfoFromJson(Map<String, dynamic> json) => DetailInfo(
      name: json['name'] as String,
      desc: json['desc'] as String? ?? '',
      playCount: json['playCount'] as String? ?? '',
      author: json['author'] as String,
      imgUrl: json['imgUrl'] as String? ?? '',
    );

Map<String, dynamic> _$DetailInfoToJson(DetailInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'desc': instance.desc,
      'playCount': instance.playCount,
      'author': instance.author,
      'imgUrl': instance.imgUrl,
    };
