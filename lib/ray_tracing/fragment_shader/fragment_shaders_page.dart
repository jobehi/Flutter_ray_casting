import 'package:flutter/material.dart';

class FragmentShadersPage extends StatefulWidget {
  const FragmentShadersPage({super.key});

  @override
  State<FragmentShadersPage> createState() => _FragmentShadersPageState();
}

class _FragmentShadersPageState extends State<FragmentShadersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fragment Shaders'),
      ),
      body: const Center(
        child: Text('Fragment Shaders'),
      ),
    );
  }
}
