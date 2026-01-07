import 'package:flutter/material.dart';
import 'package:animated_menu/animated_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Menu Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _lastAction = 'Tap anywhere to show menu';
  MenuAnimation _selectedAnimation = MenuAnimation.fadeScale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Menu Demo'),
        actions: [
          // Using AnimatedMenuButton for app bar menus
          AnimatedMenuButton(
            icon: Icons.more_vert,
            menuBuilder: (context) => AnimatedMenu(
              theme: AnimatedMenuTheme.dark,
              animationConfig: MenuAnimationConfig.scale,
              items: [
                const AnimatedMenuHeader(title: 'Options'),
                AnimatedMenuButtonItem(
                  icon: Icons.settings,
                  child: const Text('Settings'),
                  onSelected: () => _showSnackBar('Settings'),
                ),
                AnimatedMenuButtonItem(
                  icon: Icons.info_outline,
                  child: const Text('About'),
                  onSelected: () => _showSnackBar('About'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Animation selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Animation:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MenuAnimation.values.map((animation) {
                    return ChoiceChip(
                      label: Text(animation.name),
                      selected: _selectedAnimation == animation,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedAnimation = animation);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(),
          // Status text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _lastAction,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          // Main tap area
          Expanded(
            child: GestureDetector(
              onTapDown: (details) => _showContextMenu(
                context,
                details.globalPosition,
              ),
              onSecondaryTapDown: (details) => _showContextMenu(
                context,
                details.globalPosition,
              ),
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, size: 48),
                      SizedBox(height: 16),
                      Text('Tap or right-click anywhere'),
                      Text('to show the animated menu'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Example buttons row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Using AnimatedMenuAnchor for custom anchors
                AnimatedMenuAnchor(
                  alignment: Alignment.bottomCenter,
                  animationConfig: MenuAnimationConfig.bounceIn,
                  menuBuilder: (context) => AnimatedMenu(
                    theme: AnimatedMenuTheme.light,
                    items: [
                      AnimatedMenuButtonItem(
                        icon: Icons.share,
                        child: const Text('Share'),
                        onSelected: () => _showSnackBar('Share'),
                      ),
                      AnimatedMenuButtonItem(
                        icon: Icons.link,
                        child: const Text('Copy Link'),
                        onSelected: () => _showSnackBar('Copy Link'),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: null, // Handled by AnimatedMenuAnchor
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                // Using extension method
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ).withAnimatedMenu(
                  alignment: Alignment.bottomCenter,
                  animationConfig: MenuAnimationConfig.elasticIn,
                  menuBuilder: (context) => AnimatedMenu(
                    items: [
                      AnimatedMenuButtonItem(
                        icon: Icons.edit,
                        child: const Text('Edit'),
                        onSelected: () => _showSnackBar('Edit'),
                      ),
                      AnimatedMenuButtonItem(
                        icon: Icons.copy,
                        child: const Text('Duplicate'),
                        onSelected: () => _showSnackBar('Duplicate'),
                      ),
                      const AnimatedMenuDivider(),
                      AnimatedMenuButtonItem(
                        icon: Icons.delete,
                        child: const Text('Delete'),
                        isDestructive: true,
                        onSelected: () => _showSnackBar('Delete'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    showAnimatedMenu(
      context: context,
      position: position,
      animationConfig: MenuAnimationConfig(
        animation: _selectedAnimation,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      ),
      menu: AnimatedMenu(
        borderRadius: 12,
        cornerSmoothing: 0.6,
        blurSigma: 20,
        itemAnimationConfig: MenuItemAnimationConfig.fadeIn,
        items: [
          const AnimatedMenuHeader(title: 'Actions'),
          AnimatedMenuButtonItem(
            icon: Icons.copy,
            child: const Text('Copy'),
            trailing: _buildShortcut('⌘C'),
            onSelected: () => _updateAction('Copy'),
          ),
          AnimatedMenuButtonItem(
            icon: Icons.content_cut,
            child: const Text('Cut'),
            trailing: _buildShortcut('⌘X'),
            onSelected: () => _updateAction('Cut'),
          ),
          AnimatedMenuButtonItem(
            icon: Icons.paste,
            child: const Text('Paste'),
            trailing: _buildShortcut('⌘V'),
            onSelected: () => _updateAction('Paste'),
          ),
          const AnimatedMenuDivider(),
          AnimatedMenuButtonItem(
            icon: Icons.select_all,
            child: const Text('Select All'),
            trailing: _buildShortcut('⌘A'),
            onSelected: () => _updateAction('Select All'),
          ),
          const AnimatedMenuDivider(),
          const AnimatedMenuHeader(title: 'More'),
          AnimatedMenuButtonItem(
            icon: Icons.share,
            child: const Text('Share'),
            trailingIcon: Icons.arrow_forward_ios,
            onSelected: () => _updateAction('Share'),
          ),
          AnimatedMenuButtonItem(
            icon: Icons.download,
            child: const Text('Download'),
            onSelected: () => _updateAction('Download'),
          ),
          const AnimatedMenuDivider(),
          AnimatedMenuButtonItem(
            icon: Icons.delete_outline,
            child: const Text('Delete'),
            isDestructive: true,
            onSelected: () => _updateAction('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcut(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).hintColor,
      ),
    );
  }

  void _updateAction(String action) {
    setState(() => _lastAction = 'Last action: $action');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
