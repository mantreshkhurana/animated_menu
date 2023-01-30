// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:ui';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

const menuItemHeight = 0.0;
const menuDividerHeight = 0.0;
const menuPadding = 0.0;

/// Creates a [AnimatedMenu] that can be opened and closed.
class AnimatedMenu extends StatefulWidget {
  AnimatedMenu({
    required this.items,
    this.width,
    this.borderRadius = 0,
    Key? key,
  }) : super(key: key);

  /// The items to display in the [AnimatedMenu].
  var items;

  /// The width of the [AnimatedMenu].
  final double? width;

  /// The border radius of the [AnimatedMenu].
  final double borderRadius;

  @override
  State<AnimatedMenu> createState() => _AnimatedMenuState();
}

class _AnimatedMenuState extends State<AnimatedMenu> {
  double get height =>
      widget.items.fold(menuPadding * 2, (prev, e) => prev + e.height);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: SmoothBorderRadius(
            cornerRadius: widget.borderRadius, cornerSmoothing: 0.5),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: SmoothBorderRadius(
            cornerRadius: widget.borderRadius, cornerSmoothing: 0.5),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: SmoothBorderRadius(
                  cornerRadius: widget.borderRadius, cornerSmoothing: 0.5),
            ),
            padding: const EdgeInsets.all(menuPadding),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.items.toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract class AnimatedMenuEntity extends Widget {
  const AnimatedMenuEntity({Key? key}) : super(key: key);

  double get height;
}

class AnimatedMenuButtonItem extends StatefulWidget
    implements AnimatedMenuEntity {
  const AnimatedMenuButtonItem({
    required this.child,
    this.onSelected,
    this.height = menuItemHeight,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onSelected;

  @override
  final double height;

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedMenuButtonItemState createState() => _AnimatedMenuButtonItemState();
}

class _AnimatedMenuButtonItemState extends State<AnimatedMenuButtonItem> {
  bool _hover = false;
  bool _selected = false;
  bool _flashing = false;

  Timer? _closeTimer;
  Timer? _toggleFlashTimer;

  @override
  Widget build(BuildContext context) {
    bool enabled = widget.onSelected != null;

    var menu = context.findAncestorWidgetOfExactType<AnimatedMenu>();
    var menuWidth = menu?.width;
    if (menuWidth != null) menuWidth += menuPadding * 2;

    TextStyle textStyle;
    if (enabled) {
      textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(
            color:
                _hover || (_selected && _flashing) ? Colors.transparent : null,
          );
    } else {
      textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(
            color: Theme.of(context).disabledColor,
          );
    }

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          if (!_selected && enabled) {
            _hover = true;
          }
        });
      },
      onExit: (_) {
        setState(() {
          _hover = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (enabled && !_selected) {
            _handleSelection();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          width: menuWidth,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(0)),
            color: _hover || (_selected && _flashing)
                ? Theme.of(context).primaryColor
                : null,
          ),
          child: DefaultTextStyle(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSelection() {
    _selected = true;

    _closeTimer = Timer(const Duration(milliseconds: 240), () {
      Navigator.of(context).pop();
      if (widget.onSelected != null) {
        widget.onSelected!();
      }
    });

    _toggleFlash();
  }

  void _toggleFlash() {
    setState(() {
      _hover = false;
      _flashing = !_flashing;
    });

    _toggleFlashTimer = Timer(const Duration(milliseconds: 80), _toggleFlash);
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _toggleFlashTimer?.cancel();
    super.dispose();
  }
}

class AnimatedMenuButtonItemDivider extends StatelessWidget
    implements AnimatedMenuEntity {
  const AnimatedMenuButtonItemDivider({Key? key}) : super(key: key);

  @override
  double get height => menuDividerHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: menuDividerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          color: Theme.of(context).dividerColor,
          height: 1.0,
        ),
      ),
    );
  }
}
