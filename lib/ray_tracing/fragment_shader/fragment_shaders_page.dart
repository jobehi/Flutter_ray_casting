import 'dart:ui';

import 'package:flutter/material.dart';

class FragmentShadersPage extends StatefulWidget {
  const FragmentShadersPage({super.key});

  @override
  State<FragmentShadersPage> createState() => _FragmentShadersPageState();
}

class _FragmentShadersPageState extends State<FragmentShadersPage>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat();

  int _startTime = 0;
  double get _elapsedTimeInSeconds =>
      (_startTime - DateTime.now().millisecondsSinceEpoch) / 1000;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<FragmentShader> _loadShaderFrag() async {
    FragmentProgram program =
        await FragmentProgram.fromAsset('shaders/ray_tracer.frag');

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
                    shader.setFloat(
                        1, MediaQuery.of(context).size.width); //width
                    shader.setFloat(
                        2, MediaQuery.of(context).size.height); //heigh
                    _startTime = DateTime.now().millisecondsSinceEpoch;
                    return GestureDetector(
                      onPanUpdate: (details) {
                        shader.setFloat(3, details.localPosition.dx);
                        shader.setFloat(4, details.localPosition.dy);
                      },
                      child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            shader.setFloat(0, _elapsedTimeInSeconds);
                            return CustomPaint(
                              painter: ShaderPainter(shader),
                            );
                          }),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          ),
        ));
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
