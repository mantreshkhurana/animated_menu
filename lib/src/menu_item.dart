import 'package:flutter/material.dart';
import '../src/menu.dart';

const minMenuEdgePadding = 0.0;

/// Get the global bounds of a widget.
Rect getGlobalBoundsForContext(BuildContext context) {
  var renderBox = context.findRenderObject() as RenderBox;
  var overlay =
      Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;

  return Rect.fromPoints(
    renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    ),
    renderBox.localToGlobal(
      renderBox.size.bottomRight(Offset.zero),
      ancestor: overlay,
    ),
  );
}

Future showAnimatedMenu({
  /// The context in which the [AnimatedMenu] should be shown.
  required BuildContext context,

  /// The point at which the menu should be anchored.
  required Offset preferredAnchorPoint,

  /// The menu to show.
  required AnimatedMenu menu,

  /// The alignment of the menu relative to the anchor point.
  Alignment alignment = Alignment.topLeft,

  /// The semantic label for the menu.
  String? semanticLabel,

  /// Whether the menu is dismissable.
  bool isDismissable = true,

  /// Whether the menu should be shown in the root navigator.
  bool useRootNavigator = true,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  final NavigatorState navigator =
      Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push(_PopupMenuRoute(
    preferredAnchorPoint: preferredAnchorPoint,
    alignment: alignment,
    semanticLabel: semanticLabel,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    capturedThemes:
        InheritedTheme.capture(from: context, to: navigator.context),
    menu: menu,
    isDismissable: isDismissable,
  ));
}

class _PopupMenuRoute extends PopupRoute {
  _PopupMenuRoute({
    required this.preferredAnchorPoint,
    required this.alignment,
    required this.barrierLabel,
    this.semanticLabel,
    required this.capturedThemes,
    required this.menu,
    required this.isDismissable,
  });

  final Offset preferredAnchorPoint;
  final String? semanticLabel;
  final CapturedThemes capturedThemes;
  final AnimatedMenu menu;
  final Alignment alignment;
  bool isDismissable = true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  bool get barrierDismissible => isDismissable;

  @override
  Color? get barrierColor => null;

  @override
  final String barrierLabel;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _PopupMenuRouteLayout(
              preferredAnchorPoint,
              alignment,
              Directionality.of(context),
              mediaQuery.padding,
            ),
            child: capturedThemes.wrap(
              menu,
            ),
          );
        },
      ),
    );
  }
}

class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(
    this.preferredAnchorPoint,
    this.alignment,
    this.textDirection,
    this.padding,
  );

  final Offset preferredAnchorPoint;

  final Alignment alignment;

  final TextDirection textDirection;

  EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(
      const EdgeInsets.all(0.0) + padding,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    var x = preferredAnchorPoint.dx - (alignment.x + 1) / 2 * childSize.width;
    var y = preferredAnchorPoint.dy - (alignment.y + 1) / 2 * childSize.height;

    if (x < minMenuEdgePadding) {
      x = minMenuEdgePadding;
    }
    if (y < minMenuEdgePadding) {
      y = minMenuEdgePadding;
    }
    if (x > size.width - minMenuEdgePadding - childSize.width) {
      x = size.width - minMenuEdgePadding - childSize.width;
    }
    if (y > size.height - minMenuEdgePadding - childSize.height) {
      y = size.height - minMenuEdgePadding - childSize.height;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return preferredAnchorPoint != oldDelegate.preferredAnchorPoint ||
        textDirection != oldDelegate.textDirection ||
        padding != oldDelegate.padding;
  }
}
