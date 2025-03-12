import 'package:json_annotation/json_annotation.dart';

part 'song_list.g.dart';
/// 歌单标签
class SortItem {
  String name;
  String tid;
  String id;
  bool isSelect;

  SortItem({required this.name, required this.tid, required this.id, this.isSelect = false});
}

/// 歌单详情
@JsonSerializable()
class DetailInfo {
  @JsonKey()
  String name;
  @JsonKey()
  String? desc;
  @JsonKey()
  String? playCount;
  @JsonKey()
  String author;
  @JsonKey()
  String? imgUrl;

  DetailInfo({
    required this.name,
    this.desc = '',
    this.playCount = '',
    required this.author,
    this.imgUrl = '',
  });

  factory DetailInfo.fromJson(Map<String, dynamic> json) => _$DetailInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DetailInfoToJson(this);

  factory DetailInfo.empty() {
    return DetailInfo(
      author: '',
      name: '',
      desc: '',
      playCount: '',
    );
  }
}
