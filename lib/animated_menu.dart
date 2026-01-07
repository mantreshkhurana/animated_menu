/// A professional Flutter package for creating beautiful, animated popup menus
/// with smooth corners, backdrop blur, and customizable animations.
///
/// ## Features
///
/// - Smooth, continuous corners (squircle/superellipse style)
/// - Backdrop blur effect
/// - Built-in animation system with multiple presets
/// - Customizable themes (dark/light presets included)
/// - Menu items with icons, trailing widgets, and destructive styling
/// - Section headers and dividers
/// - Staggered item animations
/// - Full keyboard and accessibility support
///
/// ## Usage
///
/// ```dart
/// import 'package:animated_menu/animated_menu.dart';
///
/// // Show a menu at tap position
/// GestureDetector(
///   onTapDown: (details) {
///     showAnimatedMenu(
///       context: context,
///       position: details.globalPosition,
///       menu: AnimatedMenu(
///         items: [
///           AnimatedMenuButtonItem(
///             icon: Icons.copy,
///             child: Text('Copy'),
///             onSelected: () => handleCopy(),
///           ),
///           AnimatedMenuDivider(),
///           AnimatedMenuButtonItem(
///             icon: Icons.delete,
///             child: Text('Delete'),
///             isDestructive: true,
///             onSelected: () => handleDelete(),
///           ),
///         ],
///       ),
///     );
///   },
///   child: YourWidget(),
/// )
/// ```
///
/// ## Animation Presets
///
/// Use [MenuAnimationConfig] presets for quick setup:
/// - `MenuAnimationConfig.fadeIn` - Simple fade in
/// - `MenuAnimationConfig.scale` - Scale up animation
/// - `MenuAnimationConfig.fadeScale` - Fade with scale (default)
/// - `MenuAnimationConfig.bounceIn` - Bouncy entrance
/// - `MenuAnimationConfig.elasticIn` - Elastic spring effect
/// - `MenuAnimationConfig.slideDown` - Slide from top
/// - `MenuAnimationConfig.zoomIn` - Zoom with overshoot
///
/// ## Theme Presets
///
/// Use [AnimatedMenuTheme] presets:
/// - `AnimatedMenuTheme.dark` - Dark mode styling
/// - `AnimatedMenuTheme.light` - Light mode styling
library;

// Core menu widgets
export 'src/menu.dart';

// Menu controller and show functions
export 'src/menu_controller.dart';

// Animation system
export 'src/animations.dart';

// Smooth border radius utilities
export 'src/smooth_border_radius.dart';
