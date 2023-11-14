import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/base/base_ui.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/app/pages/song_list/controllers/song_list_controller.dart';
import 'package:lx_music_flutter/app/pages/song_list/views/song_list_detail_view.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/extensions/string_extensions.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';
import 'package:path_provider/path_provider.dart';

/// 歌单主页
class SongListView extends BaseStatefulWidget {
  const SongListView({super.key, required super.title});

  @override
  State<SongListView> createState() => _SongListState();
}

class _SongListState extends State<SongListView> {
  late SongListController songListController;

  late EasyRefreshController easyRefreshController;

  @override
  void initState() {
    songListController = Get.put(SongListController());

    easyRefreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(AppConst.navigatorKeySongList),
      onGenerateRoute: (settings) {
        print('====>>>>$settings');
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return buildBody();
          },
        );
      },
    );
  }

  Widget buildBody() {
    return Scaffold(
      drawer: buildDrawer(),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: buildTopLeftButtons(),
                ),
              ),
              Builder(builder: (ctx) {
                return Container(
                  margin: const EdgeInsets.only(left: 12, right: 12),
                  child: ElevatedButton(
                      onPressed: () {
                        Scaffold.of(ctx).openDrawer();
                      },
                      child: Obx(() => Text(songListController.currentTag['name'] ?? '默认'))),
                );
              }),
              buildTopRightButton(),
              const SizedBox(width: 10),
            ],
          ),
          Expanded(
            flex: 3,
            child: Obx(
              () => EasyRefresh(
                controller: easyRefreshController,
                header: const ClassicHeader(),
                footer: const ClassicFooter(),
                onRefresh: () async {
                  songListController.page = 1;
                  await songListController.onRefresh();

                  easyRefreshController.finishRefresh();
                  easyRefreshController.resetFooter();
                },
                onLoad: () async {
                  songListController.page++;
                  await songListController.onLoad();

                  easyRefreshController.finishLoad(
                      songListController.musicListModel.value.list.length % songListController.pageSize >=
                              songListController.pageSize
                          ? IndicatorResult.noMore
                          : IndicatorResult.success);
                },
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    return buildSongItem(index);
                  },
                  itemCount: songListController.musicListModel.value.list.length,
                  // child: ListView.builder(
                  //   itemBuilder: (context, index) {
                  //     return buildSongItem(index);
                  //   },
                  //   itemCount: songListController.songList.length,
                  // ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSongItem(int index) {
    if (songListController.musicListModel.value.list.length <= index) return Container();
    MusicListItem item = songListController.musicListModel.value.list.elementAt(index);
    String imgUrl = item.img;
    Logger.debug('buildSongItem====$imgUrl');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        Get.to(SongListDetailView(musicListItem: item), id: AppConst.navigatorKeySongList);

        // String songmid = item['songmid'];
        // for (var t in item['types']) {
        //   var result = await KWSongList.getMusicUrlDirect(songmid, t['type']);
        //   if (result['url'] != null && result['url'].isNotEmpty) {
        //     print('$songmid  ${t['type']}=======>>>>>>result=$result');
        //     item.url = result['url'];
        //   }
        //   return;
        // }
      },
      child: Container(
        child: Column(
          children: [
            Image(
                image: ExtendedNetworkImageProvider(imgUrl, cache: true),
                width: 64,
                height: 64,
                errorBuilder: (context, error, stackTrace) {
                  return DownloadImageWidget(url: imgUrl, width: 64, height: 64);
                }),
            // Image(
            //     image: NetworkImage(imgUrl, headers: {"user-agent": ''}),
            //     width: 64,
            //     height: 64,
            //     fit: BoxFit.cover,
            //     errorBuilder: (context, error, stackTrace) {
            //       return const Placeholder(fallbackWidth: 64, fallbackHeight: 64);
            //     }
            // ),
            // Text('${item['singer']}'),
            // Text('${item['albumName']}'),
            // Text('${item['interval']}'),
            Text(
              '${item.name}',
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopLeftButtons() {
    return Obx(
      () {
        List<Widget> children = [];
        for (var element in songListController.sortList) {
          children.add(Text(element.name));
        }
        return ToggleButtons(
          isSelected: songListController.sortList.map((element) => element.isSelect).toList(),
          children: children,
          onPressed: (index) {
            for (int i = 0; i < songListController.sortList.length; i++) {
              if (i == index) {
                songListController.sortList[i].isSelect = true;
              } else {
                songListController.sortList[i].isSelect = false;
              }
            }
            // setState(() {
            //
            // });
          },
        );
      },
    );
  }

  Widget buildTopRightButton() {
    List<DropdownMenuItem> children = [];
    for (var element in AppConst.platformNames) {
      children.add(
        DropdownMenuItem(
          value: element,
          child: Text(element),
        ),
      );
    }
    return Obx(
      () => DropdownButton(
        value: songListController.currentPlatform.value,
        items: children,
        onChanged: (value) {
          songListController.changePlatform(value.toString());
        },
      ),
    );
  }

  Widget buildDrawer() {
    void openTag(BuildContext context, Map item) {
      songListController.openTag(item);
      Scaffold.of(context).closeDrawer();
    }

    List<Widget> buildList(List list) {
      List<Widget> children = [];
      for (var element in list) {
        if (element['list'] == null || element['list'].isEmpty) {
          continue;
        }

        children.add(Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(
              element['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            )));

        List<Widget> tags = [];
        if (element['list'] != null) {
          element['list'].forEach((item) {
            tags.add(
              Builder(builder: (ctx) {
                return GestureDetector(
                  onTap: () {
                    openTag(ctx, item);
                  },
                  child: Container(
                    color: Colors.grey[200],
                    // margin: EdgeInsets.only(left: 4, right: 0, top: 4, bottom: 4),
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                    child: Text(item['name']),
                  ),
                );
              }),
            );
          });
          children.add(Container(
            margin: const EdgeInsets.only(left: 8, right: 8),
            child: Wrap(
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: tags,
            ),
          ));
        }
      }
      return children;
    }

    return Obx(() {
      List<Widget> children = [];

      children.addAll(buildList(songListController.tagList.value['hotTags']));
      children.addAll(buildList(songListController.tagList.value['tags']));

      children.add(const SizedBox(height: 10));
      return Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
    });
  }
}

class DownloadImageWidget extends StatefulWidget {
  const DownloadImageWidget({super.key, required this.url, this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  @override
  State<DownloadImageWidget> createState() => _DownloadImageWidgetState();
}

class _DownloadImageWidgetState extends State<DownloadImageWidget> {
  String savePath = '';

  @override
  void initState() {
    getData();
    super.initState();
  }

  String userAgent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36 Edg/118.0.2088.76";

  void getData() async {
    Directory directory = await getTemporaryDirectory();
    savePath = '${directory.path}/${widget.url.md5}';
    if (!File(savePath).existsSync()) {
      HttpCore.getInstance()
          .download(widget.url, savePath,
              options: Options(
                responseType: ResponseType.bytes,
                headers: {'user-agent': userAgent},
              ))
          .then((value) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (savePath.isEmpty) {
      return Placeholder(
        fallbackWidth: widget.width ?? 64,
        fallbackHeight: widget.height ?? 64,
      );
    }
    return Image(
      image: FileImage(File(savePath)),
      width: widget.width ?? 64,
      height: widget.height ?? 64,
      errorBuilder: (context, error, stackTrace) {
        return Placeholder(
          fallbackWidth: widget.width ?? 64,
          fallbackHeight: widget.height ?? 64,
        );
      },
    );
  }
}
