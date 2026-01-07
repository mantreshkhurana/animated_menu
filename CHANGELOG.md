# Changelog

Animated Menu Changelog

## 1.0.3

### Breaking Changes

- Removed external dependencies (`figma_squircle` and `animate_do`)
- All functionality is now built-in with zero external dependencies

### New Features

- **Built-in Animation System**: Multiple animation presets including:
  - `fadeIn`, `scale`, `fadeScale`, `bounceIn`, `elasticIn`, `zoomIn`
  - Slide animations: `slideDown`, `slideUp`, `slideLeft`, `slideRight`
  - Customizable duration, curves, and delays
- **Smooth Border Radius**: Built-in squircle/superellipse corners with `cornerSmoothing` parameter
- **AnimatedMenuController**: Class-based API for programmatic menu control
- **AnimatedMenuAnchor**: Widget wrapper for easy menu attachment
- **AnimatedMenuButton**: Ready-to-use button for app bars and toolbars
- **New Menu Item Types**:
  - `AnimatedMenuHeader`: Section headers for grouping items
  - `AnimatedMenuDivider`: Customizable dividers with indent options
  - `AnimatedMenuCustomItem`: For fully custom content
- **Theme System**:
  - `AnimatedMenuTheme` with dark/light presets
  - Full customization of colors, shadows, and text styles
- **Enhanced AnimatedMenuButtonItem**:
  - Leading and trailing icons
  - Destructive action styling (red color)
  - Custom hover/selected colors
  - Keyboard shortcuts display
- **Item Animations**: Staggered animations for menu items
- **Extension Method**: `.withAnimatedMenu()` for easy menu attachment to any widget

### Improvements

- Updated to Flutter 3.10+ and Dart 3.0+
- Better backdrop blur implementation
- Improved menu positioning and edge handling
- Full documentation with examples
- Modern API design following Flutter conventions

## 1.0.2

- Bug fixes & improvements.

## 1.0.1

- Documentation update.

## 1.0.0

- Initial release.
