import 'package:flutter/material.dart';

class Step4 extends StatefulWidget {
  const Step4({super.key});

  @override
  State<Step4> createState() => _Step4State();
}

class _Step4State extends State<Step4> {
  List<List<int>> map = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RayCasting -  2D Grid Map'),
      ),
      body: GestureDetector(
        /// add walls to map when user tap a certain cell

        onTapDown: (details) {
          final cellSize = MediaQuery.of(context).size.width / map[0].length;
          final x = (details.localPosition.dx / cellSize).floor();
          final y = (details.localPosition.dy / cellSize).floor();

          setState(() {
            map[y][x] = map[y][x] == 1 ? 0 : 1;
          });
        },

        /// drag a wall
        onPanUpdate: (details) {
          final cellSize = MediaQuery.of(context).size.width / map[0].length;
          final x = (details.localPosition.dx / cellSize).floor();
          final y = (details.localPosition.dy / cellSize).floor();

          setState(() {
            map[y][x] = 1;
          });
        },

        child: CustomPaint(
          painter: MapPainter(map: map),
          child: Container(),
        ),
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final List<List<int>> map;

  MapPainter({required this.map});
  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / map[0].length;
    final wallPaint = Paint()..color = Colors.orange;
    final emptyPaint = Paint()..color = Colors.white;

    for (int y = 0; y < map.length; y++) {
      for (int x = 0; x < map[0].length; x++) {
        final rect = Rect.fromLTWH(
          x * cellSize,
          y * cellSize,
          cellSize,
          cellSize,
        );
        canvas.drawRect(
          rect,
          map[y][x] == 1 ? wallPaint : emptyPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
