import 'package:flutter/material.dart';

import 'basic/basic_ray_tracing_page.dart';

class MainRayTracingPage extends StatefulWidget {
  const MainRayTracingPage({super.key});

  @override
  State<MainRayTracingPage> createState() => _MainRayTracingPageState();
}

class _MainRayTracingPageState extends State<MainRayTracingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ray Tracing'),
      ),
      body: PageView(
        children: const [
          BasicRayTracingWidget(),
        ],
      ),
    );
  }
}
