import 'package:flutter/material.dart';

import 'ray_casting/ray_casting_page.dart';

import 'ray_tracing/ray_tracing_page.dart';
import 'steps_explanation/steps_explanation_screen.dart';

void main() {
  runApp(const RayTracingApp());
}

class RayTracingApp extends StatelessWidget {
  const RayTracingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ray Tracing Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Painting loves Math'),
        ),
        body: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final pages = const [
    StepsExplanationScreen(),
    MazeGamePage(),
    RayTracingWidget(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility_new),
            label: 'Steps Explanation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarm),
            label: 'Ray Casting',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ac_unit),
            label: 'Ray Tracing',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
