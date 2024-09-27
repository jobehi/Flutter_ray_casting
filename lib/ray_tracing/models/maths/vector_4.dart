// matrix_4.dart
import 'vector_3.dart';
import 'dart:math';

class Matrix4 {
  final List<List<double>> m;

  Matrix4.identity() : m = List.generate(4, (_) => List.filled(4, 0.0)) {
    for (int i = 0; i < 4; i++) {
      m[i][i] = 1.0;
    }
  }

  Matrix4.rotationXYZ(double radiansX, double radiansY, double radiansZ)
      : m = List.generate(4, (_) => List.filled(4, 0.0)) {
    // Rotation around X-axis
    Matrix4 rotX = Matrix4.identity();
    rotX.m[1][1] = cos(radiansX);
    rotX.m[1][2] = -sin(radiansX);
    rotX.m[2][1] = sin(radiansX);
    rotX.m[2][2] = cos(radiansX);

    // Rotation around Y-axis
    Matrix4 rotY = Matrix4.identity();
    rotY.m[0][0] = cos(radiansY);
    rotY.m[0][2] = sin(radiansY);
    rotY.m[2][0] = -sin(radiansY);
    rotY.m[2][2] = cos(radiansY);

    // Rotation around Z-axis
    Matrix4 rotZ = Matrix4.identity();
    rotZ.m[0][0] = cos(radiansZ);
    rotZ.m[0][1] = -sin(radiansZ);
    rotZ.m[1][0] = sin(radiansZ);
    rotZ.m[1][1] = cos(radiansZ);

    // Combined rotation: Rz * Ry * Rx
    Matrix4 combined = rotZ.multiply(rotY).multiply(rotX);

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        m[i][j] = combined.m[i][j];
      }
    }
  }

  // Matrix multiplication
  Matrix4 multiply(Matrix4 other) {
    Matrix4 result = Matrix4.identity();
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        result.m[i][j] = 0.0;
        for (int k = 0; k < 4; k++) {
          result.m[i][j] += m[i][k] * other.m[k][j];
        }
      }
    }
    return result;
  }

  // Inverse of the matrix (assuming it's a rotation matrix)
  Matrix4 inverse() {
    // For rotation matrices, the inverse is the transpose
    Matrix4 inv = Matrix4.identity();
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        inv.m[i][j] = m[j][i];
      }
    }
    return inv;
  }

  // Transform a Vector3 (assuming w = 1)
  Vector3 transform(Vector3 v) {
    double x = m[0][0] * v.x + m[0][1] * v.y + m[0][2] * v.z + m[0][3];
    double y = m[1][0] * v.x + m[1][1] * v.y + m[1][2] * v.z + m[1][3];
    double z = m[2][0] * v.x + m[2][1] * v.y + m[2][2] * v.z + m[2][3];
    // Ignore w for simplicity
    return Vector3(x, y, z);
  }
}
