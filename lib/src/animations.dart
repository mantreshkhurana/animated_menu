import 'package:flutter/material.dart';

/// Animation types available for the animated menu.
enum MenuAnimation {
  /// No animation - menu appears instantly.
  none,

  /// Fade in animation.
  fadeIn,

  /// Scale up from center animation.
  scale,

  /// Slide in from top animation.
  slideDown,

  /// Slide in from bottom animation.
  slideUp,

  /// Slide in from left animation.
  slideLeft,

  /// Slide in from right animation.
  slideRight,

  /// Fade in with scale animation.
  fadeScale,

  /// Bounce scale animation.
  bounceIn,

  /// Elastic scale animation.
  elasticIn,

  /// Zoom in animation with slight overshoot.
  zoomIn,
}

/// Configuration for menu animations.
class MenuAnimationConfig {
  /// The type of animation to use.
  final MenuAnimation animation;

  /// Duration of the animation.
  final Duration duration;

  /// The curve to use for the animation.
  final Curve curve;

  /// Delay before starting the animation.
  final Duration delay;

  /// For slide animations, the offset to start from (0.0 to 1.0).
  final double slideOffset;

  /// For scale animations, the initial scale (0.0 to 1.0).
  final double initialScale;

  /// Creates a menu animation configuration.
  const MenuAnimationConfig({
    this.animation = MenuAnimation.fadeScale,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
    this.delay = Duration.zero,
    this.slideOffset = 0.3,
    this.initialScale = 0.8,
  });

  /// No animation preset.
  static const MenuAnimationConfig none = MenuAnimationConfig(
    animation: MenuAnimation.none,
  );

  /// Fast fade in preset.
  static const MenuAnimationConfig fadeIn = MenuAnimationConfig(
    animation: MenuAnimation.fadeIn,
    duration: Duration(milliseconds: 150),
    curve: Curves.easeOut,
  );

  /// Scale animation preset.
  static const MenuAnimationConfig scale = MenuAnimationConfig(
    animation: MenuAnimation.scale,
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOutBack,
    initialScale: 0.85,
  );

  /// Fade with scale preset (default).
  static const MenuAnimationConfig fadeScale = MenuAnimationConfig(
    animation: MenuAnimation.fadeScale,
    duration: Duration(milliseconds: 180),
    curve: Curves.easeOutCubic,
    initialScale: 0.9,
  );

  /// Bounce in preset.
  static const MenuAnimationConfig bounceIn = MenuAnimationConfig(
    animation: MenuAnimation.bounceIn,
    duration: Duration(milliseconds: 400),
    curve: Curves.bounceOut,
    initialScale: 0.3,
  );

  /// Elastic in preset.
  static const MenuAnimationConfig elasticIn = MenuAnimationConfig(
    animation: MenuAnimation.elasticIn,
    duration: Duration(milliseconds: 500),
    curve: Curves.elasticOut,
    initialScale: 0.5,
  );

  /// Slide down preset.
  static const MenuAnimationConfig slideDown = MenuAnimationConfig(
    animation: MenuAnimation.slideDown,
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOutCubic,
    slideOffset: 0.2,
  );

  /// Slide up preset.
  static const MenuAnimationConfig slideUp = MenuAnimationConfig(
    animation: MenuAnimation.slideUp,
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOutCubic,
    slideOffset: 0.2,
  );

  /// Zoom in preset.
  static const MenuAnimationConfig zoomIn = MenuAnimationConfig(
    animation: MenuAnimation.zoomIn,
    duration: Duration(milliseconds: 250),
    curve: Curves.easeOutBack,
    initialScale: 0.7,
  );

  /// Creates a copy with modified properties.
  MenuAnimationConfig copyWith({
    MenuAnimation? animation,
    Duration? duration,
    Curve? curve,
    Duration? delay,
    double? slideOffset,
    double? initialScale,
  }) {
    return MenuAnimationConfig(
      animation: animation ?? this.animation,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      delay: delay ?? this.delay,
      slideOffset: slideOffset ?? this.slideOffset,
      initialScale: initialScale ?? this.initialScale,
    );
  }
}

/// A widget that animates its child based on [MenuAnimationConfig].
class AnimatedMenuTransition extends StatefulWidget {
  /// The child widget to animate.
  final Widget child;

  /// The animation configuration.
  final MenuAnimationConfig config;

  /// The alignment for scale animations.
  final Alignment scaleAlignment;

  /// Creates an animated menu transition.
  const AnimatedMenuTransition({
    super.key,
    required this.child,
    this.config = const MenuAnimationConfig(),
    this.scaleAlignment = Alignment.topLeft,
  });

  @override
  State<AnimatedMenuTransition> createState() => _AnimatedMenuTransitionState();
}

class _AnimatedMenuTransitionState extends State<AnimatedMenuTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.config.duration,
    );

    _setupAnimations();

    if (widget.config.delay != Duration.zero) {
      Future.delayed(widget.config.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  void _setupAnimations() {
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.config.curve,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: widget.config.initialScale,
      end: 1.0,
    ).animate(curvedAnimation);

    // Slide animation
    Offset slideBegin;
    switch (widget.config.animation) {
      case MenuAnimation.slideDown:
        slideBegin = Offset(0, -widget.config.slideOffset);
        break;
      case MenuAnimation.slideUp:
        slideBegin = Offset(0, widget.config.slideOffset);
        break;
      case MenuAnimation.slideLeft:
        slideBegin = Offset(widget.config.slideOffset, 0);
        break;
      case MenuAnimation.slideRight:
        slideBegin = Offset(-widget.config.slideOffset, 0);
        break;
      default:
        slideBegin = Offset.zero;
    }

    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.animation == MenuAnimation.none) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget result = child!;

        switch (widget.config.animation) {
          case MenuAnimation.none:
            break;

          case MenuAnimation.fadeIn:
            result = Opacity(
              opacity: _fadeAnimation.value,
              child: result,
            );
            break;

          case MenuAnimation.scale:
            result = Transform.scale(
              scale: _scaleAnimation.value,
              alignment: widget.scaleAlignment,
              child: result,
            );
            break;

          case MenuAnimation.slideDown:
          case MenuAnimation.slideUp:
          case MenuAnimation.slideLeft:
          case MenuAnimation.slideRight:
            result = SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: result,
              ),
            );
            break;

          case MenuAnimation.fadeScale:
          case MenuAnimation.zoomIn:
            result = Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                alignment: widget.scaleAlignment,
                child: result,
              ),
            );
            break;

          case MenuAnimation.bounceIn:
          case MenuAnimation.elasticIn:
            result = Opacity(
              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                alignment: widget.scaleAlignment,
                child: result,
              ),
            );
            break;
        }

        return result;
      },
      child: widget.child,
    );
  }
}

/// Item animation types for menu items.
enum MenuItemAnimation {
  /// No animation for items.
  none,

  /// Fade in items sequentially.
  fadeIn,

  /// Slide items in from left.
  slideIn,

  /// Scale items up.
  scaleIn,
}

/// Configuration for animating individual menu items.
class MenuItemAnimationConfig {
  /// The type of animation.
  final MenuItemAnimation animation;

  /// Duration of each item's animation.
  final Duration duration;

  /// Delay between each item's animation start.
  final Duration staggerDelay;

  /// The curve for the animation.
  final Curve curve;

  /// Creates a menu item animation configuration.
  const MenuItemAnimationConfig({
    this.animation = MenuItemAnimation.none,
    this.duration = const Duration(milliseconds: 150),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.curve = Curves.easeOut,
  });

  /// No item animation preset.
  static const MenuItemAnimationConfig none = MenuItemAnimationConfig();

  /// Fade in items preset.
  static const MenuItemAnimationConfig fadeIn = MenuItemAnimationConfig(
    animation: MenuItemAnimation.fadeIn,
  );

  /// Slide in items preset.
  static const MenuItemAnimationConfig slideIn = MenuItemAnimationConfig(
    animation: MenuItemAnimation.slideIn,
    duration: Duration(milliseconds: 200),
  );

  /// Scale in items preset.
  static const MenuItemAnimationConfig scaleIn = MenuItemAnimationConfig(
    animation: MenuItemAnimation.scaleIn,
  );
}

/// Animates a menu item with staggered delay.
class AnimatedMenuItem extends StatefulWidget {
  /// The child widget.
  final Widget child;

  /// The animation configuration.
  final MenuItemAnimationConfig config;

  /// The index of this item in the list (for stagger calculation).
  final int index;

  /// Creates an animated menu item.
  const AnimatedMenuItem({
    super.key,
    required this.child,
    required this.index,
    this.config = const MenuItemAnimationConfig(),
  });

  @override
  State<AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<AnimatedMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.config.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.config.curve,
    );

    final delay = widget.config.staggerDelay * widget.index;
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.animation == MenuItemAnimation.none) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        switch (widget.config.animation) {
          case MenuItemAnimation.none:
            return child!;

          case MenuItemAnimation.fadeIn:
            return Opacity(
              opacity: _animation.value,
              child: child,
            );

          case MenuItemAnimation.slideIn:
            return Transform.translate(
              offset: Offset(-20 * (1 - _animation.value), 0),
              child: Opacity(
                opacity: _animation.value,
                child: child,
              ),
            );

          case MenuItemAnimation.scaleIn:
            return Transform.scale(
              scale: 0.8 + (0.2 * _animation.value),
              child: Opacity(
                opacity: _animation.value,
                child: child,
              ),
            );
        }
      },
      child: widget.child,
    );
  }
}

/// Hover animation effect for menu items.
class HoverScaleEffect extends StatefulWidget {
  /// The child widget.
  final Widget child;

  /// Scale factor when hovered (1.0 = no scale, 1.05 = 5% larger).
  final double hoverScale;

  /// Duration of the hover animation.
  final Duration duration;

  /// Whether the effect is enabled.
  final bool enabled;

  /// Creates a hover scale effect.
  const HoverScaleEffect({
    super.key,
    required this.child,
    this.hoverScale = 1.02,
    this.duration = const Duration(milliseconds: 100),
    this.enabled = true,
  });

  @override
  State<HoverScaleEffect> createState() => _HoverScaleEffectState();
}

class _HoverScaleEffectState extends State<HoverScaleEffect> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? widget.hoverScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Tap animation effect for menu items.
class TapScaleEffect extends StatefulWidget {
  /// The child widget.
  final Widget child;

  /// Scale factor when tapped (0.95 = 5% smaller).
  final double tapScale;

  /// Duration of the tap animation.
  final Duration duration;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Whether the effect is enabled.
  final bool enabled;

  /// Creates a tap scale effect.
  const TapScaleEffect({
    super.key,
    required this.child,
    this.tapScale = 0.95,
    this.duration = const Duration(milliseconds: 100),
    this.onTap,
    this.enabled = true,
  });

  @override
  State<TapScaleEffect> createState() => _TapScaleEffectState();
}

class _TapScaleEffectState extends State<TapScaleEffect> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return GestureDetector(
        onTap: widget.onTap,
        child: widget.child,
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) {
        setState(() => _isTapped = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isTapped = false),
      child: AnimatedScale(
        scale: _isTapped ? widget.tapScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
