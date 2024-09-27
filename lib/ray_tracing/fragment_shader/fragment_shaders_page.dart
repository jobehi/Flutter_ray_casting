import 'dart:ui';

import 'package:flutter/material.dart';

class FragmentShadersPage extends StatefulWidget {
  const FragmentShadersPage({super.key});

  @override
  State<FragmentShadersPage> createState() => _FragmentShadersPageState();
}

class _FragmentShadersPageState extends State<FragmentShadersPage> {
  bool isLoading = true;
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  Future<FragmentShader> _loadShaderFrag() async {
    FragmentProgram program =
        await FragmentProgram.fromAsset('shaders/ray_tracer.frag');
    setState(() {
      isLoading = false;
    });
    return program.fragmentShader();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fragment Shaders'),
      ),
      body: Center(
          child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<FragmentShader>(
            future: _loadShaderFrag(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final shader = snapshot.data!;
                return CustomPaint(
                  painter: ShaderPainter(shader),
                );
              } else {
                return const CircularProgressIndicator();
              }
            }),
      )),
    );
  }
}

class ShaderPainter extends CustomPainter {
  final FragmentShader shader;

  ShaderPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(ShaderPainter oldDelegate) {
    return oldDelegate.shader != shader;
  }
}
