/// 歌单标签
class SortItem {
  String name;
  String tid;
  String id;
  bool isSelect;

  SortItem({required this.name, required this.tid, required this.id, this.isSelect = false});
}

/// 歌单详情
class DetailInfo {
  String name;
  String? desc;
  String? playCount;
  String author;
  String? imgUrl;

  DetailInfo({
    required this.name,
    this.desc = '',
    this.playCount = '',
    required this.author,
    this.imgUrl = '',
  });

  factory DetailInfo.empty() {
    return DetailInfo(
      author: '',
      name: '',
      desc: '',
      playCount: '',
    );
  }
}
