import 'package:flutter/material.dart';
import 'menu.dart';
import 'animations.dart';

/// Minimum padding from screen edges.
const double kMinMenuEdgePadding = 8.0;

/// Controller for managing animated menu display and behavior.
///
/// Use [AnimatedMenuController] to show menus with full control over
/// positioning, animations, and lifecycle.
///
/// Example:
/// ```dart
/// final menuController = AnimatedMenuController();
///
/// // Show menu at tap position
/// menuController.show(
///   context: context,
///   position: tapPosition,
///   menu: AnimatedMenu(
///     items: [
///       AnimatedMenuButtonItem(
///         child: Text('Copy'),
///         icon: Icons.copy,
///         onSelected: () => handleCopy(),
///       ),
///     ],
///   ),
/// );
///
/// // Later, if needed
/// menuController.dismiss();
/// ```
class AnimatedMenuController {
  _PopupMenuRoute<dynamic>? _currentRoute;
  bool _isShowing = false;

  /// Whether a menu is currently being displayed.
  bool get isShowing => _isShowing;

  /// Shows an animated menu at the specified position.
  ///
  /// Returns a [Future] that completes when the menu is dismissed.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [position]: The anchor point for the menu (typically tap position).
  /// - [menu]: The [AnimatedMenu] widget to display.
  /// - [alignment]: How the menu aligns relative to [position].
  /// - [animationConfig]: Animation configuration for menu appearance.
  /// - [barrierDismissible]: Whether tapping outside dismisses the menu.
  /// - [barrierColor]: Color of the barrier behind the menu.
  /// - [useRootNavigator]: Whether to use the root navigator.
  /// - [semanticLabel]: Accessibility label for the menu.
  Future<void> show({
    required BuildContext context,
    required Offset position,
    required AnimatedMenu menu,
    Alignment alignment = Alignment.topLeft,
    MenuAnimationConfig animationConfig = const MenuAnimationConfig(),
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useRootNavigator = true,
    String? semanticLabel,
  }) async {
    assert(debugCheckHasMaterialLocalizations(context));

    // Dismiss any existing menu
    if (_isShowing) {
      dismiss();
    }

    final navigator = Navigator.of(context, rootNavigator: useRootNavigator);

    final route = _PopupMenuRoute<void>(
      position: position,
      alignment: alignment,
      menu: menu,
      animationConfig: animationConfig,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      semanticLabel: semanticLabel,
    );

    _currentRoute = route;
    _isShowing = true;

    await navigator.push(route);

    _isShowing = false;
    _currentRoute = null;
  }

  /// Dismisses the currently displayed menu.
  void dismiss() {
    if (_isShowing && _currentRoute != null) {
      _currentRoute!.navigator?.pop();
    }
  }
}

/// Global function to show an animated menu.
///
/// This is a convenience function that creates a temporary controller
/// and shows the menu. For more control, use [AnimatedMenuController].
///
/// Example:
/// ```dart
/// showAnimatedMenu(
///   context: context,
///   position: details.globalPosition,
///   menu: AnimatedMenu(
///     items: [
///       AnimatedMenuButtonItem(
///         child: Text('Option 1'),
///         onSelected: () => print('Selected 1'),
///       ),
///     ],
///   ),
/// );
/// ```
Future<void> showAnimatedMenu({
  required BuildContext context,
  required Offset position,
  required AnimatedMenu menu,
  Alignment alignment = Alignment.topLeft,
  MenuAnimationConfig animationConfig = const MenuAnimationConfig(),
  bool barrierDismissible = true,
  Color? barrierColor,
  bool useRootNavigator = true,
  String? semanticLabel,

  // Legacy parameter names for backward compatibility
  @Deprecated('Use position instead') Offset? preferredAnchorPoint,
  @Deprecated('Use barrierDismissible instead') bool? isDismissable,
}) {
  return AnimatedMenuController().show(
    context: context,
    position: preferredAnchorPoint ?? position,
    menu: menu,
    alignment: alignment,
    animationConfig: animationConfig,
    barrierDismissible: isDismissable ?? barrierDismissible,
    barrierColor: barrierColor,
    useRootNavigator: useRootNavigator,
    semanticLabel: semanticLabel,
  );
}

/// A widget that shows an animated menu when tapped.
///
/// This widget wraps a child and shows a menu when the user taps on it.
/// It handles gesture detection and menu positioning automatically.
///
/// Example:
/// ```dart
/// AnimatedMenuAnchor(
///   menuBuilder: (context) => AnimatedMenu(
///     items: [
///       AnimatedMenuButtonItem(
///         child: Text('Edit'),
///         icon: Icons.edit,
///         onSelected: () => handleEdit(),
///       ),
///       AnimatedMenuButtonItem(
///         child: Text('Delete'),
///         icon: Icons.delete,
///         isDestructive: true,
///         onSelected: () => handleDelete(),
///       ),
///     ],
///   ),
///   child: Icon(Icons.more_vert),
/// )
/// ```
class AnimatedMenuAnchor extends StatefulWidget {
  /// The child widget that triggers the menu.
  final Widget child;

  /// Builder function that creates the menu.
  final AnimatedMenu Function(BuildContext context) menuBuilder;

  /// The alignment of the menu relative to the anchor.
  final Alignment alignment;

  /// Animation configuration for the menu.
  final MenuAnimationConfig animationConfig;

  /// Whether the menu can be dismissed by tapping outside.
  final bool barrierDismissible;

  /// Color of the barrier behind the menu.
  final Color? barrierColor;

  /// Called when the menu is opened.
  final VoidCallback? onMenuOpened;

  /// Called when the menu is closed.
  final VoidCallback? onMenuClosed;

  /// Whether to use the tap position or the widget bounds for menu position.
  final bool useTapPosition;

  /// Offset to apply to the calculated menu position.
  final Offset positionOffset;

  /// Creates an animated menu anchor.
  const AnimatedMenuAnchor({
    super.key,
    required this.child,
    required this.menuBuilder,
    this.alignment = Alignment.topLeft,
    this.animationConfig = const MenuAnimationConfig(),
    this.barrierDismissible = true,
    this.barrierColor,
    this.onMenuOpened,
    this.onMenuClosed,
    this.useTapPosition = true,
    this.positionOffset = Offset.zero,
  });

  @override
  State<AnimatedMenuAnchor> createState() => _AnimatedMenuAnchorState();
}

class _AnimatedMenuAnchorState extends State<AnimatedMenuAnchor> {
  final _controller = AnimatedMenuController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _showMenu(details.globalPosition),
      child: widget.child,
    );
  }

  Future<void> _showMenu(Offset tapPosition) async {
    Offset position;

    if (widget.useTapPosition) {
      position = tapPosition;
    } else {
      // Use widget bounds
      final renderBox = context.findRenderObject() as RenderBox;
      final offset = renderBox.localToGlobal(Offset.zero);
      position = offset + Offset(renderBox.size.width / 2, renderBox.size.height);
    }

    position += widget.positionOffset;

    widget.onMenuOpened?.call();

    await _controller.show(
      context: context,
      position: position,
      menu: widget.menuBuilder(context),
      alignment: widget.alignment,
      animationConfig: widget.animationConfig,
      barrierDismissible: widget.barrierDismissible,
      barrierColor: widget.barrierColor,
    );

    widget.onMenuClosed?.call();
  }
}

/// A button that shows an animated menu when pressed.
///
/// Similar to [PopupMenuButton] but with animated menu support.
///
/// Example:
/// ```dart
/// AnimatedMenuButton(
///   icon: Icons.more_vert,
///   menuBuilder: (context) => AnimatedMenu(
///     items: [
///       AnimatedMenuButtonItem(
///         child: Text('Settings'),
///         icon: Icons.settings,
///         onSelected: () => openSettings(),
///       ),
///     ],
///   ),
/// )
/// ```
class AnimatedMenuButton extends StatelessWidget {
  /// The icon to display in the button.
  final IconData icon;

  /// The size of the icon.
  final double iconSize;

  /// The color of the icon.
  final Color? iconColor;

  /// Builder function that creates the menu.
  final AnimatedMenu Function(BuildContext context) menuBuilder;

  /// The alignment of the menu relative to the button.
  final Alignment alignment;

  /// Animation configuration for the menu.
  final MenuAnimationConfig animationConfig;

  /// Tooltip text for the button.
  final String? tooltip;

  /// Padding around the icon.
  final EdgeInsetsGeometry padding;

  /// Creates an animated menu button.
  const AnimatedMenuButton({
    super.key,
    required this.icon,
    required this.menuBuilder,
    this.iconSize = 24.0,
    this.iconColor,
    this.alignment = Alignment.topRight,
    this.animationConfig = const MenuAnimationConfig(),
    this.tooltip,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedMenuAnchor(
      menuBuilder: menuBuilder,
      alignment: alignment,
      animationConfig: animationConfig,
      useTapPosition: false,
      child: Tooltip(
        message: tooltip ?? '',
        child: Padding(
          padding: padding,
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// Custom popup route for the animated menu.
class _PopupMenuRoute<T> extends PopupRoute<T> {
  _PopupMenuRoute({
    required this.position,
    required this.alignment,
    required this.menu,
    required this.animationConfig,
    required this.barrierDismissible,
    required this.barrierLabel,
    required this.capturedThemes,
    this.barrierColor,
    this.semanticLabel,
  });

  final Offset position;
  final Alignment alignment;
  final AnimatedMenu menu;
  final MenuAnimationConfig animationConfig;
  @override
  final bool barrierDismissible;
  @override
  final String barrierLabel;
  final CapturedThemes capturedThemes;
  @override
  final Color? barrierColor;
  final String? semanticLabel;

  @override
  Duration get transitionDuration => animationConfig.duration;

  @override
  Duration get reverseTransitionDuration =>
      Duration(milliseconds: (animationConfig.duration.inMilliseconds * 0.5).round());

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final mediaQuery = MediaQuery.of(context);

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (context) {
          return CustomSingleChildLayout(
            delegate: _PopupMenuLayoutDelegate(
              position: position,
              alignment: alignment,
              textDirection: Directionality.of(context),
              padding: mediaQuery.padding,
            ),
            child: capturedThemes.wrap(
              AnimatedMenuTransition(
                config: animationConfig,
                scaleAlignment: _getScaleAlignment(),
                child: menu,
              ),
            ),
          );
        },
      ),
    );
  }

  Alignment _getScaleAlignment() {
    // Calculate the scale alignment based on menu position
    return Alignment(
      alignment.x,
      alignment.y,
    );
  }
}

/// Layout delegate for positioning the popup menu.
class _PopupMenuLayoutDelegate extends SingleChildLayoutDelegate {
  _PopupMenuLayoutDelegate({
    required this.position,
    required this.alignment,
    required this.textDirection,
    required this.padding,
  });

  final Offset position;
  final Alignment alignment;
  final TextDirection textDirection;
  final EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(
      const EdgeInsets.all(kMinMenuEdgePadding) + padding,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Calculate position based on alignment
    var x = position.dx - (alignment.x + 1) / 2 * childSize.width;
    var y = position.dy - (alignment.y + 1) / 2 * childSize.height;

    // Clamp to screen bounds
    final minX = kMinMenuEdgePadding + padding.left;
    final maxX = size.width - kMinMenuEdgePadding - padding.right - childSize.width;
    final minY = kMinMenuEdgePadding + padding.top;
    final maxY = size.height - kMinMenuEdgePadding - padding.bottom - childSize.height;

    x = x.clamp(minX, maxX);
    y = y.clamp(minY, maxY);

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuLayoutDelegate oldDelegate) {
    return position != oldDelegate.position ||
        alignment != oldDelegate.alignment ||
        textDirection != oldDelegate.textDirection ||
        padding != oldDelegate.padding;
  }
}

/// Extension for easily showing context menus on widgets.
extension AnimatedMenuExtension on Widget {
  /// Wraps this widget with an [AnimatedMenuAnchor].
  Widget withAnimatedMenu({
    required AnimatedMenu Function(BuildContext context) menuBuilder,
    Alignment alignment = Alignment.topLeft,
    MenuAnimationConfig animationConfig = const MenuAnimationConfig(),
    bool barrierDismissible = true,
    VoidCallback? onMenuOpened,
    VoidCallback? onMenuClosed,
  }) {
    return AnimatedMenuAnchor(
      menuBuilder: menuBuilder,
      alignment: alignment,
      animationConfig: animationConfig,
      barrierDismissible: barrierDismissible,
      onMenuOpened: onMenuOpened,
      onMenuClosed: onMenuClosed,
      child: this,
    );
  }
}

/// Gets the global bounds for a widget's build context.
Rect getGlobalBoundsForContext(BuildContext context) {
  final renderBox = context.findRenderObject() as RenderBox;
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;

  return Rect.fromPoints(
    renderBox.localToGlobal(Offset.zero, ancestor: overlay),
    renderBox.localToGlobal(
      renderBox.size.bottomRight(Offset.zero),
      ancestor: overlay,
    ),
  );
}
