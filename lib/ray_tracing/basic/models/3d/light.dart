// Light class
import 'dart:ui';

import '../maths/vector_3.dart';

class Light {
  final Vector3 position;
  final Color color;
  final double intensity;

  Light({
    required this.position,
    required this.color,
    required this.intensity,
  });
}
