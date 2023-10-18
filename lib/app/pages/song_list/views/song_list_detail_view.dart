import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/song_list/controllers/song_list_detail_controller.dart';
import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/dialog_util.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class SongListDetailView extends StatefulWidget {
  const SongListDetailView({
    super.key,
    required this.songListItem,
  });

  final Map songListItem;

  @override
  State<SongListDetailView> createState() => _SongListDetailViewState();
}

class _SongListDetailViewState extends State<SongListDetailView> {
  late SongListDetailController controller;
  late EasyRefreshController easyRefreshController;

  @override
  void initState() {
    controller = Get.put(SongListDetailController());
    controller.getListDetail(widget.songListItem);
    easyRefreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    easyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildTopWidget(),
        buildButtonWidget(),
        Expanded(child: buildListWidget()),
      ],
    );
  }

  Widget buildTopWidget() {
    Widget buildImg(String? url) {
      if (url != null && url.isNotEmpty) {
        return Image(
          image: NetworkImage(url),
          width: 70,
          height: 70,
        );
      } else {
        return const SizedBox(
          width: 40,
          height: 40,
        );
      }
    }

    Widget buildPlayCount(String playCount) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.centerLeft,
        child: Text(
          playCount,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return Obx(
      () {
        DetailInfo detailInfo = controller.detailInfo.value['info'] ?? DetailInfo.empty();
        return Container(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            children: [
              Stack(
                children: [
                  buildImg(detailInfo.imgUrl),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: buildPlayCount(detailInfo.playCount ?? ''),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detailInfo.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      detailInfo.author,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detailInfo.desc ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildListWidget() {
    return Obx(
      () => EasyRefresh(
        onRefresh: () async {
          controller.page = 1;
          await controller.getListDetail(widget.songListItem);

          easyRefreshController.finishRefresh();
          easyRefreshController.resetFooter();
        },
        onLoad: () async {
          controller.page++;
          await controller.getListDetail(widget.songListItem);

          easyRefreshController.finishLoad((controller.detailInfo['list']?.length ?? 0) % controller.pageSize >= controller.pageSize
              ? IndicatorResult.noMore
              : IndicatorResult.success);
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            var item = (controller.detailInfo['list'] as List).elementAt(index);
            return Container(
              child: Row(
                children: [
                  Container(margin: const EdgeInsets.only(left: 8, right: 8), child: Text('${index + 1}')),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          item['singer'],
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item['interval'],
                    style: const TextStyle(fontSize: 11),
                  ),
                  Builder(builder: (ctx) {
                    return IconButton(
                      onPressed: () {
                        onTapListItem(ctx, item);
                      },
                      icon: const Icon(Icons.density_medium_outlined, size: 16),
                    );
                  }),
                ],
              ),
            );
          },
          itemCount: controller.detailInfo['list']?.length ?? 0,
        ),
      ),
    );
  }

  void onTapListItem(BuildContext ctx, item) {
    List menus = [
      {
        'name': '播放',
        'onTap': () {
          Logger.debug('播放=====$item');
        },
      },
      {
        'name': '稍后播放',
        'onTap': () {
          Logger.debug('稍后播放=====$item');
        },
      },
      {
        'name': '添加到...',
        'onTap': () {
          Logger.debug('添加到=====$item');
        },
      },
      {
        'name': '分享歌曲',
        'onTap': () {
          Logger.debug('分享歌曲=====$item');
        },
      },
      {
        'name': '不喜欢',
        'onTap': () {
          Logger.debug('不喜欢=====$item');
        },
      },
    ];
    var child = MenuDialog(menus: menus);
    final RenderBox box = ctx.findRenderObject() as RenderBox;
    Offset offset = box.localToGlobal(Offset.zero);
    double x = offset.dx - child.width / 2;
    double y = offset.dy + box.size.height / 2;
    Logger.debug('Get.size:  ${Get.size}  $offset');
    if (y + child.height > Get.size.height) {
      y = y - child.height - box.size.height / 2;
    }
    DialogUtil.showDialog(child: child, x: x, y: y);
  }

  Widget buildButtonWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(onPressed: () {}, child: const Text('收藏歌单')),
        ElevatedButton(onPressed: () {
          handlePlayAll();
        }, child: const Text('播放全部')),
        ElevatedButton(
            onPressed: () {
              Get.back(id: AppConst.navigatorKeySongList);
            },
            child: const Text('返回')),
      ],
    );
  }


  void handlePlayAll() {
    print('2323223');
    String id = widget.songListItem['id'];
    String source = widget.songListItem['source'];
    List list = controller.detailInfo.value['list'];

    String listId = getListId(id, source);

  }

  String getListId(String id, String source) {
    return '${source}__${id}';
  }
}

class MenuDialog extends StatefulWidget {
  const MenuDialog({super.key, required this.menus});

  final List menus;

  final double width = 100;
  final double height = 150;

  @override
  State<MenuDialog> createState() => _MenuDialogState();
}

class _MenuDialogState extends State<MenuDialog> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (var menu in widget.menus) {
      children.add(GestureDetector(
        onTap: () {
          menu['onTap']?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 30,
          padding: const EdgeInsets.only(left: 8, right: 8),
          color: Colors.white,
          alignment: Alignment.centerLeft,
          child: Text(
            menu['name'],
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ));
    }
    return Container(
      width: 100,
      child: Column(
        children: children,
      ),
    );
  }
}
