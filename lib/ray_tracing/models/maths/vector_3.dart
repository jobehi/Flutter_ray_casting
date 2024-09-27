// vector_3.dart
import 'dart:math';

class Vector3 {
  final double x, y, z;

  Vector3(this.x, this.y, this.z);

  Vector3 add(Vector3 v) => Vector3(x + v.x, y + v.y, z + v.z);
  Vector3 subtract(Vector3 v) => Vector3(x - v.x, y - v.y, z - v.z);
  Vector3 multiply(double scalar) =>
      Vector3(x * scalar, y * scalar, z * scalar);
  double dot(Vector3 v) => x * v.x + y * v.y + z * v.z;
  Vector3 cross(Vector3 v) => Vector3(
        y * v.z - z * v.y,
        z * v.x - x * v.z,
        x * v.y - y * v.x,
      );
  double length() => sqrt(x * x + y * y + z * z);
  Vector3 normalize() {
    double len = length();
    if (len == 0) return Vector3(0, 0, 0);
    return Vector3(x / len, y / len, z / len);
  }

  @override
  String toString() => 'Vector3($x, $y, $z)';
}

// Extension for rotating around the Y-axis (Yaw)
extension Vector3YawRotation on Vector3 {
  Vector3 rotateY(double angleRadians) {
    double cosA = cos(angleRadians);
    double sinA = sin(angleRadians);
    double newX = x * cosA + z * sinA;
    double newZ = -x * sinA + z * cosA;
    return Vector3(newX, y, newZ);
  }
}

// Extension for rotating around the X-axis (Pitch)
extension Vector3PitchRotation on Vector3 {
  Vector3 rotateX(double angleRadians) {
    double cosA = cos(angleRadians);
    double sinA = sin(angleRadians);
    double newY = y * cosA - z * sinA;
    double newZ = y * sinA + z * cosA;
    return Vector3(x, newY, newZ);
  }
}

// Extension for combined Yaw and Pitch rotations
extension Vector3YawPitchRotation on Vector3 {
  Vector3 rotateYawPitch(double yawRadians, double pitchRadians) {
    return rotateY(yawRadians).rotateX(pitchRadians).normalize();
  }
}
