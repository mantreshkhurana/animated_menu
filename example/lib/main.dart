import 'package:flutter/material.dart';
import 'package:animated_menu/animated_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Column(
            children: [
              GestureDetector(
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
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
