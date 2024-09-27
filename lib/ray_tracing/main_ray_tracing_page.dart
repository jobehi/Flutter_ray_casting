import 'package:flutter/material.dart';
import 'package:ray_something/ray_tracing/fragment_shader/fragment_shaders_page.dart';

import 'basic/basic_ray_tracing_page.dart';

class MainRayTracingPage extends StatefulWidget {
  const MainRayTracingPage({super.key});

  @override
  State<MainRayTracingPage> createState() => _MainRayTracingPageState();
}

class _MainRayTracingPageState extends State<MainRayTracingPage> {
  final pageViewControllers = PageController(initialPage: 0);
  int currentPage = 0;

  final pages = const [
    BasicRayTracingWidget(),
    FragmentShadersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ray Tracing'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                    onPressed: currentPage != 0
                        ? () {
                            pageViewControllers.jumpToPage(0);
                            setState(() {
                              currentPage = 0;
                            });
                          }
                        : null,
                    child: const Text('Basic Ray Tracing')),
                FilledButton(
                    onPressed: currentPage != 1
                        ? () {
                            pageViewControllers.jumpToPage(1);
                            setState(() {
                              currentPage = 1;
                            });
                          }
                        : null,
                    child: const Text('Fragment Shaders')),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: pageViewControllers,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}
