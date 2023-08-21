import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverlayDraggerWidget extends StatefulWidget {
  const OverlayDraggerWidget({Key? key}) : super(key: key);

  @override
  State<OverlayDraggerWidget> createState() => _OverlayDraggerWidgetState();
}

class _OverlayDraggerWidgetState extends State<OverlayDraggerWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 400,
        height: 400,
        color: Colors.red,
        child:  Center(
          child: GestureDetector(child: Text('点击测试'), onTap: (){
            DragOverlay.show(context: context, view: Text('ce'));
          },),
        ),
      ),
    );
  }

  @override
  void dispose() {
    DragOverlay.remove();
    super.dispose();
  }
}

/// 可拖拽悬浮的控件
class DragOverlay {
  static Widget? view;
  static OverlayEntry? _holder;

  static void remove() {
    _holder?.remove();
    _holder = null;
    view = null;
  }

  static void show({required BuildContext context, required Widget view}) {
    if(DragOverlay.view == view) {
      return;
    }
    remove();
    print('======${MediaQuery.of(context).size.height}');

    DragOverlay.view = view;
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        top: MediaQuery.of(context).size.height * 0.8,
        right: 0,
        child: _buildDraggable(context),
      );
    });
    Overlay.of(context)!.insert(overlayEntry);
    _holder = overlayEntry;
  }

  static _buildDraggable(context) {
    return Draggable(
      feedback: view!,
      onDragStarted: () {},
      onDragEnd: (detail) {
        //放手时候创建一个DragTarget
        createDragTarget(offset: detail.offset, context: context);
      },
      //当拖拽的时候就展示空
      childWhenDragging: Container(),
      ignoringFeedbackSemantics: false,
      child: view!,
    );
  }

  static void createDragTarget({required Offset offset, required BuildContext context}) {
    if (_holder != null) {
      _holder!.remove();
    }
    _holder = OverlayEntry(builder: (context) {
      bool isLeft = true;
      if (offset.dx + 100 > MediaQuery.of(context).size.width / 2) {
        isLeft = false;
      }
      double maxY = MediaQuery.of(context).size.height - 100;

      return Positioned(
        top: offset.dy < 50
            ? 50
            : offset.dy > maxY
                ? maxY
                : offset.dy,
        left: isLeft ? 0 : null,
        right: isLeft ? null : 0,
        child: _buildDraggable(context),
      );
    });
    Overlay.of(context)!.insert(_holder!);
  }
}
