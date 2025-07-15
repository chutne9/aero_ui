import 'package:aero_ui/rect_transform/rect_transform_controller.dart';
import 'package:aero_ui/rect_transform/sizer.dart';
import 'package:flutter/material.dart';

class RectTransform extends StatefulWidget {
  const RectTransform({
    super.key,
    required this.controller,
    required this.padding,
    this.strokeSize = 0.8,
    this.strokeHandleSize = 4,
    this.cornerSizerSize = 8,
    this.rotatorSize = 16,
    this.moveable = true,
  });

  final RectTransformController controller;
  final double padding;
  final double strokeSize;
  final double strokeHandleSize;
  final double cornerSizerSize;
  final double rotatorSize;
  final bool moveable;

  @override
  State<RectTransform> createState() => _RectTransformState();
}

class _RectTransformState extends State<RectTransform> {
  final stackKey = GlobalKey();
  Offset? _center;
  Offset? _lastDragVector;

  @override
  Widget build(BuildContext context) {
    final edgeSizerOffset = widget.padding;
    final cornerHandleOffset =
        widget.padding - widget.rotatorSize / 2 - widget.cornerSizerSize / 3;
    return Stack(
      key: stackKey,
      children: [
        Positioned(
          top: edgeSizerOffset,
          left: edgeSizerOffset,
          right: edgeSizerOffset,
          bottom: edgeSizerOffset,
          child: _buildMoveHandle(context),
        ),
        Positioned(
          top: edgeSizerOffset,
          left: edgeSizerOffset,
          right: edgeSizerOffset,
          height: widget.strokeHandleSize,
          child: _buildEdgeResizeHandle(context, Sizer.top),
        ),
        Positioned(
          bottom: edgeSizerOffset,
          left: edgeSizerOffset,
          right: edgeSizerOffset,
          height: widget.strokeHandleSize,
          child: _buildEdgeResizeHandle(context, Sizer.bottom),
        ),
        Positioned(
          top: edgeSizerOffset,
          bottom: edgeSizerOffset,
          left: edgeSizerOffset,
          width: widget.strokeHandleSize,
          child: _buildEdgeResizeHandle(context, Sizer.left),
        ),
        Positioned(
          top: edgeSizerOffset,
          bottom: edgeSizerOffset,
          right: edgeSizerOffset,
          width: widget.strokeHandleSize,
          child: _buildEdgeResizeHandle(context, Sizer.right),
        ),
        Positioned(
          top: cornerHandleOffset,
          left: cornerHandleOffset,
          width: widget.rotatorSize,
          height: widget.rotatorSize,
          child: Stack(
            children: [
              _buildRotatorHandle(),
              Align(
                alignment: Alignment.bottomRight,
                child: _buildCornerResizeHandle(context, Sizer.topLeft),
              ),
            ],
          ),
        ),
        Positioned(
          top: cornerHandleOffset,
          right: cornerHandleOffset,
          width: widget.rotatorSize,
          height: widget.rotatorSize,
          child: Stack(
            children: [
              _buildRotatorHandle(),
              Align(
                alignment: Alignment.bottomLeft,
                child: _buildCornerResizeHandle(context, Sizer.topRight),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: cornerHandleOffset,
          left: cornerHandleOffset,
          width: widget.rotatorSize,
          height: widget.rotatorSize,
          child: Stack(
            children: [
              _buildRotatorHandle(),
              Align(
                alignment: Alignment.topRight,
                child: _buildCornerResizeHandle(context, Sizer.bottomLeft),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: cornerHandleOffset,
          right: cornerHandleOffset,
          width: widget.rotatorSize,
          height: widget.rotatorSize,
          child: Stack(
            children: [
              _buildRotatorHandle(),
              _buildCornerResizeHandle(context, Sizer.bottomRight),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoveHandle(BuildContext context) {
    return widget.moveable
        ? GestureDetector(
            onPanUpdate: (details) {
              widget.controller.move(details.delta);
            },
          )
        : SizedBox.shrink();
  }

  Widget _buildEdgeResizeHandle(BuildContext context, Sizer sizer) {
    bool hasWidth = sizer == Sizer.left || sizer == Sizer.right;
    bool hasHeight = sizer == Sizer.top || sizer == Sizer.bottom;

    return GestureDetector(
      onPanStart: (details) {
        widget.controller.startResize(sizer);
      },
      onPanUpdate: (details) {
        widget.controller.resize(details.delta);
      },
      onPanEnd: (details) {
        widget.controller.endResize();
      },
      child: MouseRegion(
        cursor: sizer.cursor,
        child: Container(
          alignment: sizer.alignment,
          width: hasWidth ? widget.strokeHandleSize : null,
          height: hasHeight ? widget.strokeHandleSize : null,
          child: Container(
            width: hasWidth ? widget.strokeSize : null,
            height: hasHeight ? widget.strokeSize : null,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }

  Widget _buildCornerResizeHandle(BuildContext context, Sizer sizer) {
    return GestureDetector(
      onPanStart: (details) {
        widget.controller.startResize(sizer);
      },
      onPanUpdate: (details) {
        widget.controller.resize(details.delta);
      },
      onPanEnd: (details) {
        widget.controller.endResize();
      },
      child: MouseRegion(
        cursor: sizer.cursor,
        child: Container(
          alignment: Alignment.center,
          width: widget.cornerSizerSize,
          height: widget.cornerSizerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }

  Widget _buildRotatorHandle() {
    return GestureDetector(
      onPanStart: _onRotateStart,
      onPanUpdate: _onRotateUpdate,
      onPanEnd: _onRotateEnd,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        hitTestBehavior: HitTestBehavior.translucent,
        child: Container(
          width: widget.rotatorSize,
          height: widget.rotatorSize,
          decoration: BoxDecoration(shape: BoxShape.circle),
        ),
      ),
    );
  }

  Offset _getCenter() {
    final renderBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final localCenter = Offset(size.width / 2, size.height / 2);
    return renderBox.localToGlobal(localCenter);
  }

  void _onRotateStart(DragStartDetails details) {
    _center = _getCenter();
    _lastDragVector = details.globalPosition - _center!;
  }

  void _onRotateUpdate(DragUpdateDetails details) {
    if (_center == null || _lastDragVector == null) return;

    final currentDragVector = details.globalPosition - _center!;

    final angleDelta = currentDragVector.direction - _lastDragVector!.direction;

    if (angleDelta.abs() > 0.001) {
      widget.controller.rotate(angleDelta);
    }

    _lastDragVector = currentDragVector;
  }

  void _onRotateEnd(DragEndDetails details) {
    _center = null;
    _lastDragVector = null;
  }
}
