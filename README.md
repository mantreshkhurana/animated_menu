# Animated Menu

[![GitHub stars](https://img.shields.io/github/stars/mantreshkhurana/animated_menu.svg?style=social)](https://github.com/mantreshkhurana/animated_menu)
[![pub package](https://img.shields.io/pub/v/animated_menu.svg)](https://pub.dartlang.org/packages/animated_menu)

Use `AnimatedMenu` to create a menu with/without animation. You can use `FadeIn` or `SlideIn` animation to show the menu, You can use any Widget inside `AnimatedMenu` as a menu item.

![Screenshot](https://raw.githubusercontent.com/mantreshkhurana/animated_menu/stable/screenshots/screenshot-1.png)

## Installation

Add `animated_menu: ^1.0.0` in your project's pubspec.yaml:

```yaml
dependencies:
  animated_menu: ^1.0.0
```

## Usage

Import `animated_menu` in your dart file:

```dart
import 'package:animated_menu/animated_menu.dart';
```

Then use `showAnimatedMenu` in your function:

```dart
onTapDown: (details) {
  showAnimatedMenu(
    context: context,
    preferredAnchorPoint: Offset(
      details.globalPosition.dx,
      details.globalPosition.dy,
    ),
    isDismissable: true,
    useRootNavigator: true,
    menu: AnimatedMenu(
      items: [
        FadeIn(
          child: Material(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 170,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: const [
                  SizedBox(height: 10),
                  Text('Item 1'),
                  Divider(),
                  Text('Item 2'),
                  Divider(),
                  Text('Item 3'),
                  Divider(),
                  Text('Item 4'),
                  Divider(),
                  Text('Item 5'),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
},
```
