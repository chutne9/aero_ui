import 'dart:math';
import 'package:aero_ui/rect_transform/sizer.dart';
import 'package:flutter/material.dart';

class RectTransformController extends ChangeNotifier {
  Rect bounds = Rect.zero;
  double angle = 0;

  Sizer? _activeSizer;

  void move(Offset delta) {
    if (delta == Offset.zero) {
      return;
    }
    final rotatedDelta = _rotateVector(delta, angle);
    final currentBounds = bounds;
    bounds = Rect.fromLTWH(
      currentBounds.left + rotatedDelta.dx,
      currentBounds.top + rotatedDelta.dy,
      currentBounds.width,
      currentBounds.height,
    );
    notifyListeners();
  }

  void startResize(Sizer sizer) {
    _activeSizer = sizer;
  }

  void endResize() {
    _activeSizer = null;
  }

  void resize(Offset localDelta) {
    final sizer = _activeSizer;
    if (sizer == null) return;

    final oldBounds = bounds;
    final growth = sizer.growthDirection;

    final dw = localDelta.dx * growth.dx;
    final dh = localDelta.dy * growth.dy;

    var newWidth = oldBounds.width + dw;
    var newHeight = oldBounds.height + dh;

    final localCenterShift = Offset(dw * growth.dx / 2, dh * growth.dy / 2);
    final rotatedCenterShift = _rotateVector(localCenterShift, angle);
    final newCenter = oldBounds.center + rotatedCenterShift;

    Sizer newSizer = sizer;
    if (newWidth < 0) {
      newWidth = -newWidth;
      newSizer = newSizer.flipHorizontally();
    }
    if (newHeight < 0) {
      newHeight = -newHeight;
      newSizer = newSizer.flipVertically();
    }

    bounds = Rect.fromCenter(
      center: newCenter,
      width: newWidth,
      height: newHeight,
    );

    notifyListeners();
  }

  void rotate(double angleDelta) {
    angle += angleDelta;
    notifyListeners();
  }

  Offset _rotateVector(Offset vector, double angle) {
    final cosA = cos(angle);
    final sinA = sin(angle);
    final x = vector.dx * cosA - vector.dy * sinA;
    final y = vector.dx * sinA + vector.dy * cosA;
    return Offset(x, y);
  }
}
