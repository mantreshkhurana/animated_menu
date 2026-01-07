# Animated Menu

[![GitHub stars](https://img.shields.io/github/stars/mantreshkhurana/animated_menu.svg?style=social)](https://github.com/mantreshkhurana/animated_menu)
[![pub package](https://img.shields.io/pub/v/animated_menu.svg)](https://pub.dartlang.org/packages/animated_menu)

A professional Flutter package for creating beautiful, animated popup menus with smooth corners, backdrop blur, and customizable animations. **Zero external dependencies** - everything is built-in.

![Screenshot](https://raw.githubusercontent.com/mantreshkhurana/animated_menu/stable/screenshots/screenshot-1.png)

## Features

- **Smooth Corners**: iOS/macOS-style continuous corners (squircle)
- **Backdrop Blur**: Beautiful blur effect behind the menu
- **Built-in Animations**: Multiple animation presets (fade, scale, bounce, elastic, slide, etc.)
- **Theme Support**: Dark/light presets and full customization
- **Rich Menu Items**: Icons, keyboard shortcuts, destructive actions
- **Multiple APIs**: Function-based, widget-based, and extension methods
- **Zero Dependencies**: No external packages required

## Installation

Add `animated_menu` to your `pubspec.yaml`:

```yaml
dependencies:
  animated_menu: ^1.0.3
```

## Quick Start

```dart
import 'package:animated_menu/animated_menu.dart';

// Show menu on tap
GestureDetector(
  onTapDown: (details) {
    showAnimatedMenu(
      context: context,
      position: details.globalPosition,
      menu: AnimatedMenu(
        items: [
          AnimatedMenuButtonItem(
            icon: Icons.copy,
            child: Text('Copy'),
            onSelected: () => print('Copy!'),
          ),
          AnimatedMenuDivider(),
          AnimatedMenuButtonItem(
            icon: Icons.delete,
            child: Text('Delete'),
            isDestructive: true,
            onSelected: () => print('Delete!'),
          ),
        ],
      ),
    );
  },
  child: YourWidget(),
)
```

## Usage Examples

### Basic Menu

```dart
showAnimatedMenu(
  context: context,
  position: tapPosition,
  menu: AnimatedMenu(
    items: [
      AnimatedMenuButtonItem(
        icon: Icons.edit,
        child: Text('Edit'),
        onSelected: () => handleEdit(),
      ),
      AnimatedMenuButtonItem(
        icon: Icons.share,
        child: Text('Share'),
        onSelected: () => handleShare(),
      ),
    ],
  ),
);
```

### With Animation Presets

```dart
showAnimatedMenu(
  context: context,
  position: position,
  animationConfig: MenuAnimationConfig.bounceIn, // or .elasticIn, .scale, .fadeIn
  menu: AnimatedMenu(
    items: [...],
  ),
);
```

### With Theme

```dart
AnimatedMenu(
  theme: AnimatedMenuTheme.dark, // or .light
  items: [...],
)
```

### Custom Theme

```dart
AnimatedMenu(
  theme: AnimatedMenuTheme(
    backgroundColor: Colors.grey[900],
    hoverColor: Colors.grey[800],
    textStyle: TextStyle(color: Colors.white),
    iconColor: Colors.white70,
  ),
  items: [...],
)
```

### With Section Headers

```dart
AnimatedMenu(
  items: [
    AnimatedMenuHeader(title: 'Actions'),
    AnimatedMenuButtonItem(
      icon: Icons.copy,
      child: Text('Copy'),
      trailing: Text('⌘C'),
      onSelected: () {},
    ),
    AnimatedMenuButtonItem(
      icon: Icons.paste,
      child: Text('Paste'),
      trailing: Text('⌘V'),
      onSelected: () {},
    ),
    AnimatedMenuDivider(),
    AnimatedMenuHeader(title: 'Danger Zone'),
    AnimatedMenuButtonItem(
      icon: Icons.delete,
      child: Text('Delete'),
      isDestructive: true,
      onSelected: () {},
    ),
  ],
)
```

### Using AnimatedMenuAnchor Widget

```dart
AnimatedMenuAnchor(
  menuBuilder: (context) => AnimatedMenu(
    items: [
      AnimatedMenuButtonItem(
        child: Text('Option 1'),
        onSelected: () {},
      ),
    ],
  ),
  child: ElevatedButton(
    onPressed: null,
    child: Text('Show Menu'),
  ),
)
```

### Using AnimatedMenuButton (for App Bars)

```dart
AppBar(
  actions: [
    AnimatedMenuButton(
      icon: Icons.more_vert,
      menuBuilder: (context) => AnimatedMenu(
        theme: AnimatedMenuTheme.dark,
        items: [
          AnimatedMenuButtonItem(
            icon: Icons.settings,
            child: Text('Settings'),
            onSelected: () {},
          ),
        ],
      ),
    ),
  ],
)
```

### Using Extension Method

```dart
MyWidget().withAnimatedMenu(
  menuBuilder: (context) => AnimatedMenu(
    items: [...],
  ),
)
```

### Using AnimatedMenuController

```dart
final menuController = AnimatedMenuController();

// Show menu
menuController.show(
  context: context,
  position: tapPosition,
  menu: AnimatedMenu(items: [...]),
);

// Dismiss programmatically
menuController.dismiss();
```

## Animation Presets

| Preset | Description |
|--------|-------------|
| `MenuAnimationConfig.none` | No animation |
| `MenuAnimationConfig.fadeIn` | Simple fade in |
| `MenuAnimationConfig.scale` | Scale up with easeOutBack |
| `MenuAnimationConfig.fadeScale` | Fade + scale (default) |
| `MenuAnimationConfig.bounceIn` | Bouncy entrance |
| `MenuAnimationConfig.elasticIn` | Elastic spring effect |
| `MenuAnimationConfig.slideDown` | Slide from top |
| `MenuAnimationConfig.slideUp` | Slide from bottom |
| `MenuAnimationConfig.zoomIn` | Zoom with overshoot |

### Custom Animation

```dart
MenuAnimationConfig(
  animation: MenuAnimation.fadeScale,
  duration: Duration(milliseconds: 250),
  curve: Curves.easeOutBack,
  initialScale: 0.8,
)
```

## Menu Item Types

| Widget | Description |
|--------|-------------|
| `AnimatedMenuButtonItem` | Clickable item with text, icons |
| `AnimatedMenuDivider` | Visual separator |
| `AnimatedMenuHeader` | Section header text |
| `AnimatedMenuCustomItem` | Custom content |

## AnimatedMenu Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `items` | `List<AnimatedMenuEntity>` | required | Menu items |
| `width` | `double?` | null | Fixed width |
| `minWidth` | `double?` | 120 | Minimum width |
| `maxWidth` | `double?` | 320 | Maximum width |
| `borderRadius` | `double` | 12 | Corner radius |
| `cornerSmoothing` | `double` | 0.6 | Squircle smoothing (0-1) |
| `blurSigma` | `double` | 20 | Backdrop blur amount |
| `enableBlur` | `bool` | true | Enable blur effect |
| `theme` | `AnimatedMenuTheme?` | null | Theme configuration |
| `animationConfig` | `MenuAnimationConfig` | default | Menu animation |
| `itemAnimationConfig` | `MenuItemAnimationConfig` | none | Item animations |

## AnimatedMenuButtonItem Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `child` | `Widget` | required | Item content |
| `onSelected` | `VoidCallback?` | null | Selection callback |
| `icon` | `IconData?` | null | Leading icon |
| `trailingIcon` | `IconData?` | null | Trailing icon |
| `trailing` | `Widget?` | null | Trailing widget |
| `isDestructive` | `bool` | false | Red destructive style |
| `height` | `double` | 44 | Item height |

## Migration from 1.0.2

The `animate_do` package is no longer required. Replace:

```dart
// Old (1.0.2)
FadeIn(
  child: AnimatedMenuButtonItem(...),
)

// New (1.0.3)
AnimatedMenu(
  animationConfig: MenuAnimationConfig.fadeIn,
  items: [
    AnimatedMenuButtonItem(...),
  ],
)
```

The `preferredAnchorPoint` parameter is now `position` (old name still works).

## License

MIT License - see [LICENSE](LICENSE) for details.
