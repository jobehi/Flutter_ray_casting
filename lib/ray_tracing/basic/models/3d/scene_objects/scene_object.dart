// Abstract Object class
import 'dart:ui';

import '../../maths/ray.dart';

abstract class SceneObject {
  Color color;

  SceneObject({required this.color});

  // Returns the distance to the intersection point, or null if no intersection
  double? intersect(Ray ray);
}
