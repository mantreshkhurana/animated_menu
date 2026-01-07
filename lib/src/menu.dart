import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'smooth_border_radius.dart';
import 'animations.dart';

/// Default constants for menu styling.
const double kMenuItemHeight = 44.0;
const double kMenuDividerHeight = 9.0;
const double kMenuPadding = 4.0;
const double kMenuHorizontalPadding = 8.0;
const double kMenuItemBorderRadius = 6.0;
const double kDefaultBlurSigma = 20.0;
const double kDefaultBorderRadius = 12.0;
const double kDefaultCornerSmoothing = 0.6;

/// Theme configuration for the animated menu.
class AnimatedMenuTheme {
  /// Background color of the menu.
  final Color? backgroundColor;

  /// Border color of the menu.
  final Color? borderColor;

  /// Border width of the menu.
  final double borderWidth;

  /// Shadow color of the menu.
  final Color shadowColor;

  /// Shadow blur radius.
  final double shadowBlurRadius;

  /// Shadow offset.
  final Offset shadowOffset;

  /// Text style for menu items.
  final TextStyle? textStyle;

  /// Color when item is hovered.
  final Color? hoverColor;

  /// Color when item is selected/pressed.
  final Color? selectedColor;

  /// Color for disabled items.
  final Color? disabledColor;

  /// Divider color.
  final Color? dividerColor;

  /// Icon color for menu items.
  final Color? iconColor;

  /// Creates a menu theme.
  const AnimatedMenuTheme({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.5,
    this.shadowColor = Colors.black26,
    this.shadowBlurRadius = 20,
    this.shadowOffset = const Offset(0, 8),
    this.textStyle,
    this.hoverColor,
    this.selectedColor,
    this.disabledColor,
    this.dividerColor,
    this.iconColor,
  });

  /// Dark theme preset.
  static const AnimatedMenuTheme dark = AnimatedMenuTheme(
    backgroundColor: Color(0xFF2C2C2E),
    borderColor: Color(0xFF3A3A3C),
    hoverColor: Color(0xFF3A3A3C),
    selectedColor: Color(0xFF48484A),
    dividerColor: Color(0xFF3A3A3C),
    textStyle: TextStyle(color: Colors.white, fontSize: 14),
    iconColor: Colors.white70,
  );

  /// Light theme preset.
  static const AnimatedMenuTheme light = AnimatedMenuTheme(
    backgroundColor: Color(0xFFF2F2F7),
    borderColor: Color(0xFFD1D1D6),
    hoverColor: Color(0xFFE5E5EA),
    selectedColor: Color(0xFFD1D1D6),
    dividerColor: Color(0xFFD1D1D6),
    textStyle: TextStyle(color: Colors.black87, fontSize: 14),
    iconColor: Colors.black54,
  );

  /// Creates a copy with modified properties.
  AnimatedMenuTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    Color? shadowColor,
    double? shadowBlurRadius,
    Offset? shadowOffset,
    TextStyle? textStyle,
    Color? hoverColor,
    Color? selectedColor,
    Color? disabledColor,
    Color? dividerColor,
    Color? iconColor,
  }) {
    return AnimatedMenuTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      textStyle: textStyle ?? this.textStyle,
      hoverColor: hoverColor ?? this.hoverColor,
      selectedColor: selectedColor ?? this.selectedColor,
      disabledColor: disabledColor ?? this.disabledColor,
      dividerColor: dividerColor ?? this.dividerColor,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}

/// An animated popup menu with customizable styling and animations.
///
/// The [AnimatedMenu] widget creates a beautiful, animated popup menu
/// with support for smooth corners (squircle), backdrop blur, and
/// various animation options.
///
/// Example:
/// ```dart
/// showAnimatedMenu(
///   context: context,
///   preferredAnchorPoint: tapPosition,
///   menu: AnimatedMenu(
///     items: [
///       AnimatedMenuButtonItem(
///         child: Text('Option 1'),
///         onSelected: () => print('Selected 1'),
///       ),
///       AnimatedMenuDivider(),
///       AnimatedMenuButtonItem(
///         child: Text('Option 2'),
///         onSelected: () => print('Selected 2'),
///       ),
///     ],
///   ),
/// );
/// ```
class AnimatedMenu extends StatefulWidget {
  /// The items to display in the menu.
  ///
  /// Should be a list of [AnimatedMenuEntity] widgets such as
  /// [AnimatedMenuButtonItem] or [AnimatedMenuDivider].
  final List<AnimatedMenuEntity> items;

  /// The width of the menu.
  ///
  /// If not specified, the menu will size itself to fit its content.
  final double? width;

  /// The minimum width of the menu.
  final double? minWidth;

  /// The maximum width of the menu.
  final double? maxWidth;

  /// The border radius of the menu corners.
  final double borderRadius;

  /// The corner smoothing factor for squircle-style corners.
  ///
  /// A value of 0.0 produces standard circular corners.
  /// A value of 1.0 produces fully continuous (squircle) corners.
  /// Default is 0.6 for a balanced look.
  final double cornerSmoothing;

  /// The padding inside the menu.
  final EdgeInsetsGeometry padding;

  /// The blur sigma for the backdrop filter.
  ///
  /// Set to 0 to disable blur. Default is 20.0.
  final double blurSigma;

  /// Whether to enable the backdrop blur effect.
  final bool enableBlur;

  /// The theme configuration for the menu.
  ///
  /// If not specified, colors will be derived from the current [Theme].
  final AnimatedMenuTheme? theme;

  /// Animation configuration for the menu appearance.
  final MenuAnimationConfig animationConfig;

  /// Animation configuration for individual menu items.
  final MenuItemAnimationConfig itemAnimationConfig;

  /// The elevation of the menu shadow.
  final double elevation;

  /// Custom decoration for the menu container.
  ///
  /// If provided, this overrides the default decoration.
  final BoxDecoration? decoration;

  /// Creates an animated menu.
  const AnimatedMenu({
    super.key,
    required this.items,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.borderRadius = kDefaultBorderRadius,
    this.cornerSmoothing = kDefaultCornerSmoothing,
    this.padding = const EdgeInsets.symmetric(
      vertical: kMenuPadding,
      horizontal: kMenuHorizontalPadding,
    ),
    this.blurSigma = kDefaultBlurSigma,
    this.enableBlur = true,
    this.theme,
    this.animationConfig = const MenuAnimationConfig(),
    this.itemAnimationConfig = const MenuItemAnimationConfig(),
    this.elevation = 8,
    this.decoration,
  });

  @override
  State<AnimatedMenu> createState() => _AnimatedMenuState();
}

class _AnimatedMenuState extends State<AnimatedMenu> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final menuTheme = widget.theme;

    // Resolve colors from theme
    final surfaceColor = themeData.colorScheme.surface;
    final backgroundColor = menuTheme?.backgroundColor ??
        surfaceColor.withValues(alpha: 0.9);
    final borderColor = menuTheme?.borderColor ?? themeData.dividerColor;
    final shadowColor = menuTheme?.shadowColor ?? Colors.black26;

    // Build border radius
    final smoothBorderRadius = SmoothBorderRadius(
      cornerRadius: widget.borderRadius,
      cornerSmoothing: widget.cornerSmoothing,
    );

    // Build decoration
    final effectiveDecoration = widget.decoration ??
        BoxDecoration(
          color: widget.enableBlur
              ? backgroundColor.withValues(alpha: 0.8)
              : backgroundColor,
          border: Border.all(
            color: borderColor,
            width: menuTheme?.borderWidth ?? 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: menuTheme?.shadowBlurRadius ?? widget.elevation * 2,
              offset: menuTheme?.shadowOffset ?? Offset(0, widget.elevation),
            ),
          ],
        );

    // Build the menu content
    Widget menuContent = Container(
      decoration: effectiveDecoration.copyWith(
        borderRadius: smoothBorderRadius,
      ),
      child: SmoothClipRRect(
        borderRadius: smoothBorderRadius,
        cornerSmoothing: widget.cornerSmoothing,
        child: _buildBlurContainer(
          child: Container(
            padding: widget.padding,
            constraints: BoxConstraints(
              minWidth: widget.minWidth ?? 120,
              maxWidth: widget.maxWidth ?? 320,
            ),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildItems(),
              ),
            ),
          ),
        ),
      ),
    );

    // Apply fixed width if specified
    if (widget.width != null) {
      menuContent = SizedBox(
        width: widget.width,
        child: menuContent,
      );
    }

    // Wrap with menu theme provider
    return _AnimatedMenuScope(
      theme: widget.theme,
      child: menuContent,
    );
  }

  Widget _buildBlurContainer({required Widget child}) {
    if (!widget.enableBlur || widget.blurSigma <= 0) {
      return child;
    }

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: widget.blurSigma,
        sigmaY: widget.blurSigma,
      ),
      child: child,
    );
  }

  List<Widget> _buildItems() {
    final items = <Widget>[];

    for (var i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];

      // Wrap with item animation if configured
      if (widget.itemAnimationConfig.animation != MenuItemAnimation.none) {
        items.add(
          AnimatedMenuItem(
            index: i,
            config: widget.itemAnimationConfig,
            child: item,
          ),
        );
      } else {
        items.add(item);
      }
    }

    return items;
  }
}

/// Provides theme data to descendant menu widgets.
class _AnimatedMenuScope extends InheritedWidget {
  final AnimatedMenuTheme? theme;

  const _AnimatedMenuScope({
    required this.theme,
    required super.child,
  });

  static _AnimatedMenuScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AnimatedMenuScope>();
  }

  @override
  bool updateShouldNotify(_AnimatedMenuScope oldWidget) {
    return theme != oldWidget.theme;
  }
}

/// Base class for all menu item entities.
abstract class AnimatedMenuEntity extends Widget {
  const AnimatedMenuEntity({super.key});

  /// The height of this menu entity.
  double get height;
}

/// A clickable menu item with text and optional icon.
///
/// Example:
/// ```dart
/// AnimatedMenuButtonItem(
///   icon: Icons.copy,
///   child: Text('Copy'),
///   onSelected: () => handleCopy(),
/// )
/// ```
class AnimatedMenuButtonItem extends StatefulWidget
    implements AnimatedMenuEntity {
  /// The primary content of the menu item.
  final Widget child;

  /// Called when the menu item is selected.
  ///
  /// If null, the item will be displayed in a disabled state.
  final VoidCallback? onSelected;

  /// The height of the menu item.
  @override
  final double height;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional trailing icon.
  final IconData? trailingIcon;

  /// Optional trailing widget (takes precedence over trailingIcon).
  final Widget? trailing;

  /// Custom text style for this item.
  final TextStyle? textStyle;

  /// Custom hover color for this item.
  final Color? hoverColor;

  /// Custom selected color for this item.
  final Color? selectedColor;

  /// The border radius for the item highlight.
  final double itemBorderRadius;

  /// Whether to show a flash/blink animation on selection.
  final bool showSelectionFlash;

  /// Duration before the menu closes after selection.
  final Duration closeDelay;

  /// Whether to enable tap scale animation.
  final bool enableTapAnimation;

  /// Whether to enable hover scale animation.
  final bool enableHoverAnimation;

  /// Whether this item represents a destructive action (shows in red).
  final bool isDestructive;

  /// Creates an animated menu button item.
  const AnimatedMenuButtonItem({
    super.key,
    required this.child,
    this.onSelected,
    this.height = kMenuItemHeight,
    this.icon,
    this.trailingIcon,
    this.trailing,
    this.textStyle,
    this.hoverColor,
    this.selectedColor,
    this.itemBorderRadius = kMenuItemBorderRadius,
    this.showSelectionFlash = true,
    this.closeDelay = const Duration(milliseconds: 150),
    this.enableTapAnimation = true,
    this.enableHoverAnimation = false,
    this.isDestructive = false,
  });

  @override
  State<AnimatedMenuButtonItem> createState() => _AnimatedMenuButtonItemState();
}

class _AnimatedMenuButtonItemState extends State<AnimatedMenuButtonItem> {
  bool _hover = false;
  bool _selected = false;
  bool _flashing = false;

  Timer? _closeTimer;
  Timer? _toggleFlashTimer;

  bool get _enabled => widget.onSelected != null;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final menuScope = _AnimatedMenuScope.of(context);
    final menuTheme = menuScope?.theme;

    // Determine colors
    Color? backgroundColor;
    if (_selected && _flashing) {
      backgroundColor =
          widget.selectedColor ?? menuTheme?.selectedColor ?? themeData.primaryColor;
    } else if (_hover && _enabled) {
      backgroundColor = widget.hoverColor ??
          menuTheme?.hoverColor ??
          themeData.hoverColor.withValues(alpha: 0.1);
    }

    // Text color
    Color textColor;
    if (!_enabled) {
      textColor = menuTheme?.disabledColor ?? themeData.disabledColor;
    } else if (widget.isDestructive) {
      textColor = Colors.red;
    } else if (_hover || (_selected && _flashing)) {
      textColor = menuTheme?.textStyle?.color ??
          themeData.textTheme.bodyMedium?.color ??
          Colors.black87;
    } else {
      textColor = menuTheme?.textStyle?.color ??
          themeData.textTheme.bodyMedium?.color ??
          Colors.black87;
    }

    // Icon color
    final iconColor = widget.isDestructive
        ? Colors.red
        : menuTheme?.iconColor ?? textColor.withValues(alpha: 0.7);

    // Build text style
    final effectiveTextStyle = (widget.textStyle ??
            menuTheme?.textStyle ??
            themeData.textTheme.bodyMedium ??
            const TextStyle())
        .copyWith(color: textColor);

    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (_enabled && !_selected) {
          setState(() => _hover = true);
        }
      },
      onExit: (_) {
        setState(() => _hover = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _enabled && !_selected ? _handleSelection : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.itemBorderRadius),
          ),
          child: DefaultTextStyle(
            style: effectiveTextStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 18,
                    color: iconColor,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(child: widget.child),
                if (widget.trailing != null)
                  widget.trailing!
                else if (widget.trailingIcon != null)
                  Icon(
                    widget.trailingIcon,
                    size: 16,
                    color: iconColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSelection() {
    if (!_enabled) return;

    setState(() => _selected = true);

    if (widget.showSelectionFlash) {
      _toggleFlash();
    }

    _closeTimer = Timer(widget.closeDelay, () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSelected?.call();
      }
    });
  }

  void _toggleFlash() {
    if (!mounted) return;

    setState(() {
      _hover = false;
      _flashing = !_flashing;
    });

    if (_closeTimer?.isActive ?? false) {
      _toggleFlashTimer =
          Timer(const Duration(milliseconds: 50), _toggleFlash);
    }
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _toggleFlashTimer?.cancel();
    super.dispose();
  }
}

/// A visual divider between menu items.
///
/// Example:
/// ```dart
/// AnimatedMenu(
///   items: [
///     AnimatedMenuButtonItem(child: Text('Item 1')),
///     AnimatedMenuDivider(),
///     AnimatedMenuButtonItem(child: Text('Item 2')),
///   ],
/// )
/// ```
class AnimatedMenuDivider extends StatelessWidget
    implements AnimatedMenuEntity {
  /// The height of the divider including padding.
  @override
  final double height;

  /// The thickness of the divider line.
  final double thickness;

  /// The indent from the left edge.
  final double indent;

  /// The indent from the right edge.
  final double endIndent;

  /// Custom color for the divider.
  final Color? color;

  /// Creates an animated menu divider.
  const AnimatedMenuDivider({
    super.key,
    this.height = kMenuDividerHeight,
    this.thickness = 0.5,
    this.indent = 12,
    this.endIndent = 12,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final menuScope = _AnimatedMenuScope.of(context);
    final dividerColor =
        color ?? menuScope?.theme?.dividerColor ?? themeData.dividerColor;

    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          height: thickness,
          margin: EdgeInsets.only(left: indent, right: endIndent),
          color: dividerColor,
        ),
      ),
    );
  }
}

/// A section header for grouping menu items.
///
/// Example:
/// ```dart
/// AnimatedMenu(
///   items: [
///     AnimatedMenuHeader(title: 'Actions'),
///     AnimatedMenuButtonItem(child: Text('Copy')),
///     AnimatedMenuButtonItem(child: Text('Paste')),
///   ],
/// )
/// ```
class AnimatedMenuHeader extends StatelessWidget implements AnimatedMenuEntity {
  /// The title text for the header.
  final String title;

  /// The height of the header.
  @override
  final double height;

  /// Custom text style for the header.
  final TextStyle? textStyle;

  /// Creates an animated menu header.
  const AnimatedMenuHeader({
    super.key,
    required this.title,
    this.height = 28,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title.toUpperCase(),
            style: textStyle ??
                themeData.textTheme.labelSmall?.copyWith(
                  color: themeData.hintColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
        ),
      ),
    );
  }
}

/// A custom menu item that can contain any widget.
///
/// Use this when you need complete control over the item's appearance.
class AnimatedMenuCustomItem extends StatelessWidget
    implements AnimatedMenuEntity {
  /// The custom widget to display.
  final Widget child;

  /// The height of the item.
  @override
  final double height;

  /// Creates a custom menu item.
  const AnimatedMenuCustomItem({
    super.key,
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: child,
    );
  }
}

// Legacy support - keep old class names as aliases
/// @Deprecated('Use [AnimatedMenuDivider] instead')
typedef AnimatedMenuButtonItemDivider = AnimatedMenuDivider;
