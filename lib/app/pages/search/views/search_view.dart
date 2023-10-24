import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/base/base_ui.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/services/music_player_service.dart';
import 'package:lx_music_flutter/utils/player/music_player.dart';
import 'package:lx_music_flutter/utils/toast_util.dart';

import '../controllers/search_song_controller.dart';

class SearchViewWidget extends BaseStatefulWidget {
  const SearchViewWidget({
    super.key,
    required super.title,
  });

  @override
  State<SearchViewWidget> createState() => _SearchViewWidgetState();
}

class _SearchViewWidgetState extends State<SearchViewWidget> {
  late SearchSongController searchSongController;
  late EasyRefreshController easyRefreshController;

  @override
  void initState() {
    searchSongController = Get.put(SearchSongController());

    easyRefreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    super.initState();
  }

  Widget buildMenuWidget() {
    List<DropdownMenuItem> children = [];
    for (var element in AppConst.platformNames) {
      children.add(
        DropdownMenuItem(
          alignment: Alignment.center,
          value: element,
          child: Text(element, style: TextStyle(fontSize: 12),),
        ),
      );
    }
    return Container(
      alignment: Alignment.center,
      child: DropdownButton(
        elevation: 0,
        padding: EdgeInsets.zero,
        value: searchSongController.currentPlatform.value,
        items: children,
        alignment: Alignment.center,
        onChanged: (value) {
          searchSongController.changePlatform(value.toString());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        leadingWidth: 88,
        leading: Obx(() =>buildMenuWidget()),
        onSearch: (value) {
          searchSongController.songList.clear();
          searchSongController.search();
        },
        onChanged: (value) {
          searchSongController.keyword = value;
        },
        // onRightTap: () {
        //   searchSongController.songList.clear();
        //   searchSongController.search();
        // },
      ),
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
          if (searchSongController.keyword.isEmpty) {
            ToastUtil.show('请输入关键字');
            return;
          }
          if (!mounted) {
            return;
          }

          searchSongController.page = 0;
          searchSongController.search();

          easyRefreshController.finishRefresh();
          easyRefreshController.resetFooter();
        },
        onLoad: () async {
          if (searchSongController.keyword.isEmpty) {
            ToastUtil.show('请输入关键字');
            return;
          }
          if (!mounted) {
            return;
          }
          searchSongController.page++;
          await searchSongController.search();
          easyRefreshController.finishLoad(
              searchSongController.songList.length % searchSongController.pageSize >= searchSongController.pageSize
                  ? IndicatorResult.noMore
                  : IndicatorResult.success);
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            MusicItem item = searchSongController.songList.elementAt(index);
            return buildItem(item);
          },
          itemCount: searchSongController.songList.length,
        ),
      ),
    );
  }

  Widget buildItem(MusicItem item) {
    return Card(
      child: Container(
        alignment: Alignment.center,
        height: 80,
        child: Row(
          children: [
            Expanded(
                child: Text(
              item.songName,
              maxLines: 2,
            )),
            IconButton(
                onPressed: () async {
                  MusicPlayer().add(item);
                },
                icon: const Icon(Icons.play_arrow_outlined)),
            IconButton(
                onPressed: () {
                  MusicPlayerService().download(item);
                },
                icon: const Icon(Icons.download_outlined)),
          ],
        ),
      ),
    );
  }
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    this.borderRadius = 10,
    this.autoFocus = false,
    this.focusNode,
    this.controller,
    this.height = 40,
    this.value,
    this.leading,
    this.leadingWidth,
    this.backgroundColor,
    this.suffix,
    this.actions = const [],
    this.hintText,
    this.onTap,
    this.onClear,
    this.onCancel,
    this.onChanged,
    this.onSearch,
    this.onRightTap,
  });

  final double? borderRadius;
  final bool? autoFocus;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  // 输入框高度 默认40
  final double height;

  // 默认值
  final String? value;

  // 最前面的组件
  final Widget? leading;

  final double? leadingWidth;

  // 背景色
  final Color? backgroundColor;

  // 搜索框内部后缀组件
  final Widget? suffix;

  // 搜索框右侧组件
  final List<Widget> actions;

  // 输入框提示文字
  final String? hintText;

  // 输入框点击回调
  final VoidCallback? onTap;

  // 清除输入框内容回调
  final VoidCallback? onClear;

  // 清除输入框内容并取消输入
  final VoidCallback? onCancel;

  // 输入框内容改变
  final ValueChanged<String>? onChanged;

  // 点击键盘搜索
  final ValueChanged<String>? onSearch;

  // 点击右边widget
  final VoidCallback? onRightTap;

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _SearchAppBarState extends State<SearchAppBar> {
  TextEditingController? _controller;
  FocusNode? _focusNode;

  bool get isFocus => _focusNode?.hasFocus ?? false; //是否获取焦点

  bool get isTextEmpty => _controller?.text.isEmpty ?? false; //输入框是否为空

  bool get isActionEmpty => widget.actions.isEmpty; // 右边布局是否为空

  bool isShowCancel = false;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.value != null) _controller?.text = widget.value ?? "";
    // 焦点获取失去监听
    _focusNode?.addListener(() => setState(() {}));
    // 文本输入监听
    _controller?.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  // 清除输入框内容
  void _onClearInput() {
    setState(() {
      _controller?.clear();
    });
    widget.onClear?.call();
  }

  // 取消输入框编辑失去焦点
  void _onCancelInput() {
    setState(() {
      _controller?.clear();
      _focusNode?.unfocus(); //失去焦点
    });
    // 执行onCancel
    widget.onCancel?.call();
  }

  Widget _suffix() {
    if (!isTextEmpty) {
      return InkWell(
        onTap: _onClearInput,
        child: SizedBox(
          width: widget.height,
          height: widget.height,
          child: Icon(Icons.cancel, size: 22, color: Color(0xFF999999)),
        ),
      );
    }
    return widget.suffix ?? SizedBox();
  }

  List<Widget> _actions() {
    List<Widget> list = [];
    if (isFocus || !isTextEmpty) {
      list.add(InkWell(
        onTap: widget.onRightTap ?? _onCancelInput,
        child: Container(
          constraints: BoxConstraints(minWidth: 48),
          alignment: Alignment.center,
          child: const Text(
            '搜索',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
            ),
          ),
        ),
      ));
    } else if (!isActionEmpty) {
      list.addAll(widget.actions);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor,
      //阴影z轴
      elevation: 0,
      // 标题与其他控件的间隔
      titleSpacing: 0,
      leadingWidth: widget.leadingWidth ?? 40,
      leading: widget.leading ??
          InkWell(
            child: const Icon(
              Icons.arrow_back_ios_outlined,
              color: Color(0xFF666666),
              size: 16,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
      title: Container(
          margin: const EdgeInsetsDirectional.only(end: 10),
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
          ),
          child: Container(
            child: Row(
              children: [
                SizedBox(
                  width: widget.height,
                  height: widget.height,
                  child: const Icon(Icons.search, size: 20, color: Color(0xFF999999)),
                ),
                Expanded(
                  // 权重
                  flex: 1,
                  child: TextField(
                    autofocus: widget.autoFocus ?? false,
                    // 是否自动获取焦点
                    focusNode: _focusNode,
                    // 焦点控制
                    controller: _controller,
                    // 与输入框交互控制器
                    //装饰
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: widget.hintText ?? '请输入关键字',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                    // 键盘动作右下角图标
                    textInputAction: TextInputAction.search,
                    onTap: widget.onTap,
                    // 输入框内容改变回调
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSearch, //输入框完成触发
                  ),
                ),
                _suffix(),
              ],
            ),
          )),
      actions: _actions(),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }
}
