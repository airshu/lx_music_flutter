import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/platforms/kw/song_list/kw_list_controller.dart';


class KWListView extends StatefulWidget {
  const KWListView({super.key, required this.playlistid});

  final String playlistid;

  @override
  State<KWListView> createState() => _KWListViewState();
}

class _KWListViewState extends State<KWListView> {

  late KWListController controller;

  late EasyRefreshController easyRefreshController;

  @override
  void initState() {
    easyRefreshController = EasyRefreshController(
      controlFinishRefresh: false,
      controlFinishLoad: false,
    );

    controller = Get.put(KWListController());
    controller.search(widget.playlistid);
    super.initState();
  }


  @override
  void dispose() {
    Get.delete<KWListController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: buildListWidget(),
    );
  }

  Widget buildListWidget() {
    return Obx(
          () => EasyRefresh(
        controller: easyRefreshController,
        header: const ClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: () async {
          if (!mounted) {
            return;
          }

          controller.page = 0;
          controller.search(widget.playlistid);

          easyRefreshController.finishRefresh();
          easyRefreshController.resetFooter();
        },
        onLoad: () async {
          if (!mounted) {
            return;
          }
          controller.page++;
          await controller.search(widget.playlistid);
          easyRefreshController.finishLoad(
              controller.songList.length % controller.pageSize >= controller.pageSize
                  ? IndicatorResult.noMore
                  : IndicatorResult.success);
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            // MusicItem item = kwController.songList.elementAt(index);
            // return buildItem(item);
            var item = controller.songList.elementAt(index);
            print('=====>>>>>>>>$item');
            return Text('${index}');
            return buildItem(item);
          },
          itemCount: controller.songList.length,
        ),
      ),
    );
  }

  Widget buildItem(Map item) {
    return GestureDetector(
      onTap: () async {

      },
      child: Container(
        child: Row(
          children: [
            Image.network(item['pic'], cacheWidth: 100,),
            Expanded(child: Text("${item['name']}".replaceAll("&nbsp;", " "), maxLines: 3, overflow: TextOverflow.ellipsis,),),
          ],
        ),
      ),
    );
  }
}
