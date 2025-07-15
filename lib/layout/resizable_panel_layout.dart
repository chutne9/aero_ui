import 'dart:math' as math;
import 'package:flutter/material.dart';

class ResizablePanelLayout extends StatefulWidget {
  final List<Widget> children;
  final Axis direction;
  final List<double>? initialFlexFactors;
  final double dividerThickness;
  final Color dividerColor;
  final Color dividerHandleColor;
  final double minPanelRatio;

  const ResizablePanelLayout({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.initialFlexFactors,
    this.dividerThickness = 2.0,
    this.dividerColor = Colors.black26,
    this.dividerHandleColor = Colors.black54,
    this.minPanelRatio = 0.1,
  });

  @override
  State<ResizablePanelLayout> createState() => _ResizablePanelLayoutState();
}

class _ResizablePanelLayoutState extends State<ResizablePanelLayout> {
  late List<double> _flexFactors;
  late double _minAbsoluteFlex;

  @override
  void initState() {
    super.initState();
    _initializeFlexFactors();
  }

  @override
  void didUpdateWidget(ResizablePanelLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length ||
        widget.initialFlexFactors != oldWidget.initialFlexFactors) {
      _initializeFlexFactors();
    }
  }

  void _initializeFlexFactors() {
    if (widget.children.isEmpty) {
      _flexFactors = [];
      _minAbsoluteFlex = 0.1;
      return;
    }

    if (widget.initialFlexFactors != null &&
        widget.initialFlexFactors!.length == widget.children.length &&
        widget.initialFlexFactors!.every((flex) => flex > 0)) {
      _flexFactors = List<double>.from(widget.initialFlexFactors!);
    } else {
      _flexFactors = List.filled(widget.children.length, 1.0);
    }
    _normalizeFlexFactors(targetSum: widget.children.length.toDouble());

    _minAbsoluteFlex = widget.minPanelRatio;
  }

  void _normalizeFlexFactors({double? targetSum}) {
    if (_flexFactors.isEmpty) return;
    final currentSum = _flexFactors.reduce((a, b) => a + b);
    if (currentSum == 0) {
      _flexFactors = List.filled(widget.children.length, 1.0);
      return;
    }
    final sumToUse = targetSum ?? widget.children.length.toDouble();
    for (int i = 0; i < _flexFactors.length; i++) {
      _flexFactors[i] = (_flexFactors[i] / currentSum) * sumToUse;
    }
  }

  void _onDragUpdate(
    DragUpdateDetails details,
    int splitterIndex,
    double totalSize,
  ) {
    if (totalSize == 0) return;

    double delta = (widget.direction == Axis.horizontal)
        ? details.delta.dx
        : details.delta.dy;

    double totalFlex = _flexFactors.reduce((a, b) => a + b);
    double flexDelta = (delta / totalSize) * totalFlex;

    double newFlex1 = _flexFactors[splitterIndex] + flexDelta;
    double newFlex2 = _flexFactors[splitterIndex + 1] - flexDelta;

    if (newFlex1 < _minAbsoluteFlex) {
      final diff = _minAbsoluteFlex - newFlex1;
      newFlex1 = _minAbsoluteFlex;
      newFlex2 -= diff;
    }
    if (newFlex2 < _minAbsoluteFlex) {
      final diff = _minAbsoluteFlex - newFlex2;
      newFlex2 = _minAbsoluteFlex;
      newFlex1 -= diff;
    }

    newFlex1 = math.max(_minAbsoluteFlex, newFlex1);
    newFlex2 = math.max(_minAbsoluteFlex, newFlex2);

    setState(() {
      _flexFactors[splitterIndex] = newFlex1;
      _flexFactors[splitterIndex + 1] = newFlex2;
    });
  }

  Widget _buildDivider(int splitterIndex, double totalSize) {
    return MouseRegion(
      cursor: widget.direction == Axis.horizontal
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) =>
            _onDragUpdate(details, splitterIndex, totalSize),
        child: SizedBox(
          width: widget.direction == Axis.horizontal
              ? widget.dividerThickness
              : double.infinity,
          height: widget.direction == Axis.vertical
              ? widget.dividerThickness
              : double.infinity,
          child: Container(
            color: widget.dividerColor,
            alignment: Alignment.center,
            child: Container(
              // Small handle bar
              width: widget.direction == Axis.horizontal
                  ? widget.dividerThickness / 2
                  : widget.dividerThickness * 3,
              height: widget.direction == Axis.vertical
                  ? widget.dividerThickness / 2
                  : widget.dividerThickness * 3,
              decoration: BoxDecoration(
                color: widget.dividerHandleColor,
                borderRadius: BorderRadius.circular(
                  widget.dividerThickness / 4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }
    if (widget.children.length == 1) {
      return widget.children.first;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize = widget.direction == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;

        List<Widget> layoutChildren = [];
        for (int i = 0; i < widget.children.length; i++) {
          final int flexInt = math.max(1, (_flexFactors[i] * 1000).round());
          layoutChildren.add(
            Flexible(flex: flexInt, child: widget.children[i]),
          );

          if (i < widget.children.length - 1) {
            layoutChildren.add(_buildDivider(i, totalSize));
          }
        }

        return widget.direction == Axis.horizontal
            ? Row(children: layoutChildren)
            : Column(children: layoutChildren);
      },
    );
  }
}
