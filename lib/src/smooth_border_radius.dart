import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// A border radius implementation that creates smooth, continuous corners
/// similar to iOS/macOS design language (also known as squircle or superellipse).
///
/// Unlike standard [BorderRadius] which uses circular arcs, [SmoothBorderRadius]
/// creates corners with continuous curvature that smoothly transitions from
/// the straight edges to the curved corner.
class SmoothBorderRadius extends BorderRadius {
  /// The smoothness factor for the corners.
  ///
  /// A value of 0.0 produces standard circular corners.
  /// A value of 1.0 produces fully continuous (squircle) corners.
  /// Values between 0.0 and 1.0 produce intermediate smoothness.
  final double cornerSmoothing;

  /// Creates a border radius with the same radius for all corners.
  SmoothBorderRadius({
    required double cornerRadius,
    this.cornerSmoothing = 0.6,
  }) : super.all(Radius.circular(cornerRadius));

  /// Creates a border radius with the same radius for all corners.
  SmoothBorderRadius.all(
    Radius radius, {
    this.cornerSmoothing = 0.6,
  }) : super.all(radius);

  /// Creates a border radius with only the given non-zero values.
  SmoothBorderRadius.only({
    Radius topLeft = Radius.zero,
    Radius topRight = Radius.zero,
    Radius bottomLeft = Radius.zero,
    Radius bottomRight = Radius.zero,
    this.cornerSmoothing = 0.6,
  }) : super.only(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        );

  /// Creates a border radius with circular corners.
  SmoothBorderRadius.circular(
    double radius, {
    this.cornerSmoothing = 0.6,
  }) : super.circular(radius);

  /// Creates a [SmoothRectangleBorder] shape from this border radius.
  SmoothRectangleBorder toShape() {
    return SmoothRectangleBorder(
      borderRadius: this,
      cornerSmoothing: cornerSmoothing,
    );
  }

  @override
  SmoothBorderRadius copyWith({
    Radius? topLeft,
    Radius? topRight,
    Radius? bottomLeft,
    Radius? bottomRight,
    double? cornerSmoothing,
  }) {
    return SmoothBorderRadius.only(
      topLeft: topLeft ?? this.topLeft,
      topRight: topRight ?? this.topRight,
      bottomLeft: bottomLeft ?? this.bottomLeft,
      bottomRight: bottomRight ?? this.bottomRight,
      cornerSmoothing: cornerSmoothing ?? this.cornerSmoothing,
    );
  }
}

/// A rectangular border with smooth, continuous corners.
///
/// This shape can be used with [Container], [ClipPath], or any widget
/// that accepts a [ShapeBorder].
class SmoothRectangleBorder extends OutlinedBorder {
  /// The border radius with smooth corners.
  final SmoothBorderRadius borderRadius;

  /// The smoothness factor for the corners.
  final double cornerSmoothing;

  SmoothRectangleBorder({
    SmoothBorderRadius? borderRadius,
    this.cornerSmoothing = 0.6,
    super.side,
  }) : borderRadius = borderRadius ?? SmoothBorderRadius(cornerRadius: 0);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _createSmoothPath(
      rect.deflate(side.width),
      borderRadius,
      cornerSmoothing,
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _createSmoothPath(rect, borderRadius, cornerSmoothing);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;

    final paint = side.toPaint();
    final path = getOuterPath(rect);
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius.only(
        topLeft: Radius.elliptical(
          borderRadius.topLeft.x * t,
          borderRadius.topLeft.y * t,
        ),
        topRight: Radius.elliptical(
          borderRadius.topRight.x * t,
          borderRadius.topRight.y * t,
        ),
        bottomLeft: Radius.elliptical(
          borderRadius.bottomLeft.x * t,
          borderRadius.bottomLeft.y * t,
        ),
        bottomRight: Radius.elliptical(
          borderRadius.bottomRight.x * t,
          borderRadius.bottomRight.y * t,
        ),
        cornerSmoothing: cornerSmoothing,
      ),
      cornerSmoothing: cornerSmoothing,
      side: side.scale(t),
    );
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return SmoothRectangleBorder(
      borderRadius: borderRadius,
      cornerSmoothing: cornerSmoothing,
      side: side ?? this.side,
    );
  }
}

/// Creates a smooth path with continuous corners (squircle/superellipse).
Path _createSmoothPath(
  Rect rect,
  BorderRadius borderRadius,
  double smoothing,
) {
  final path = Path();

  // Clamp smoothing between 0 and 1
  final s = smoothing.clamp(0.0, 1.0);

  // Get corner radii, clamping to half the smallest dimension
  final maxRadius = math.min(rect.width, rect.height) / 2;

  final tlRadius = math.min(borderRadius.topLeft.x, maxRadius);
  final trRadius = math.min(borderRadius.topRight.x, maxRadius);
  final brRadius = math.min(borderRadius.bottomRight.x, maxRadius);
  final blRadius = math.min(borderRadius.bottomLeft.x, maxRadius);

  // If no smoothing, use standard rounded rectangle
  if (s == 0) {
    path.addRRect(RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(tlRadius),
      topRight: Radius.circular(trRadius),
      bottomRight: Radius.circular(brRadius),
      bottomLeft: Radius.circular(blRadius),
    ));
    return path;
  }

  // Create smooth corners using bezier curves
  // The smoothing factor affects how much the curve extends beyond the corner

  // Top left corner
  path.moveTo(rect.left, rect.top + tlRadius);
  if (tlRadius > 0) {
    _addSmoothCorner(
      path,
      rect.left,
      rect.top,
      tlRadius,
      s,
      _Corner.topLeft,
    );
  }

  // Top edge and top right corner
  path.lineTo(rect.right - trRadius, rect.top);
  if (trRadius > 0) {
    _addSmoothCorner(
      path,
      rect.right,
      rect.top,
      trRadius,
      s,
      _Corner.topRight,
    );
  }

  // Right edge and bottom right corner
  path.lineTo(rect.right, rect.bottom - brRadius);
  if (brRadius > 0) {
    _addSmoothCorner(
      path,
      rect.right,
      rect.bottom,
      brRadius,
      s,
      _Corner.bottomRight,
    );
  }

  // Bottom edge and bottom left corner
  path.lineTo(rect.left + blRadius, rect.bottom);
  if (blRadius > 0) {
    _addSmoothCorner(
      path,
      rect.left,
      rect.bottom,
      blRadius,
      s,
      _Corner.bottomLeft,
    );
  }

  path.close();
  return path;
}

enum _Corner { topLeft, topRight, bottomRight, bottomLeft }

/// Adds a smooth corner to the path using cubic bezier curves.
/// The smoothing factor determines how "squircle-like" the corner appears.
void _addSmoothCorner(
  Path path,
  double cornerX,
  double cornerY,
  double radius,
  double smoothing,
  _Corner corner,
) {
  // Calculate control point distance based on smoothing
  // Higher smoothing = control points closer to corner = more squircle-like
  // Standard circle uses ~0.552 ratio for bezier approximation
  // Squircle uses values closer to the radius
  const baseRatio = 0.552;
  const squircleRatio = 0.9;
  final ratio = lerpDouble(baseRatio, squircleRatio, smoothing)!;
  final controlDistance = radius * ratio;

  switch (corner) {
    case _Corner.topLeft:
      path.cubicTo(
        cornerX, cornerY + radius - controlDistance, // Control 1
        cornerX + radius - controlDistance, cornerY, // Control 2
        cornerX + radius, cornerY, // End point
      );
      break;
    case _Corner.topRight:
      path.cubicTo(
        cornerX - radius + controlDistance, cornerY, // Control 1
        cornerX, cornerY + radius - controlDistance, // Control 2
        cornerX, cornerY + radius, // End point
      );
      break;
    case _Corner.bottomRight:
      path.cubicTo(
        cornerX, cornerY - radius + controlDistance, // Control 1
        cornerX - radius + controlDistance, cornerY, // Control 2
        cornerX - radius, cornerY, // End point
      );
      break;
    case _Corner.bottomLeft:
      path.cubicTo(
        cornerX + radius - controlDistance, cornerY, // Control 1
        cornerX, cornerY - radius + controlDistance, // Control 2
        cornerX, cornerY - radius, // End point
      );
      break;
  }
}

/// A clipper that clips using smooth corners.
class SmoothRectangleClipper extends CustomClipper<Path> {
  final SmoothBorderRadius borderRadius;
  final double cornerSmoothing;

  SmoothRectangleClipper({
    required this.borderRadius,
    this.cornerSmoothing = 0.6,
  });

  @override
  Path getClip(Size size) {
    return _createSmoothPath(
      Rect.fromLTWH(0, 0, size.width, size.height),
      borderRadius,
      cornerSmoothing,
    );
  }

  @override
  bool shouldReclip(SmoothRectangleClipper oldClipper) {
    return borderRadius != oldClipper.borderRadius ||
        cornerSmoothing != oldClipper.cornerSmoothing;
  }
}

/// A widget that clips its child using smooth, continuous corners.
class SmoothClipRRect extends StatelessWidget {
  /// The child widget to clip.
  final Widget child;

  /// The border radius with smooth corners.
  final SmoothBorderRadius borderRadius;

  /// The smoothness factor for the corners.
  final double cornerSmoothing;

  const SmoothClipRRect({
    super.key,
    required this.child,
    required this.borderRadius,
    this.cornerSmoothing = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SmoothRectangleClipper(
        borderRadius: borderRadius,
        cornerSmoothing: cornerSmoothing,
      ),
      child: child,
    );
  }
}
