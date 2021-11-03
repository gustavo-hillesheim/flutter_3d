import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/models.dart';

class Object3DRenderer extends StatelessWidget {
  final double focalLength;
  final double? width;
  final double? height;
  final Object3D object;

  const Object3DRenderer({
    Key? key,
    required this.focalLength,
    required this.object,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return CustomPaint(
        size: Size(
          width ?? constraints.maxWidth,
          height ?? constraints.maxHeight,
        ),
        painter: Object3DPainter(focalLength: focalLength, object: object),
      );
    });
  }
}

class Object3DPainter extends CustomPainter {
  final double focalLength;
  final Object3D object;

  Object3DPainter({
    required this.focalLength,
    required this.object,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()..color = Colors.blue;

    final rotatedVertices = _rotate(object.vertices,
        rotation: object.rotation, aroundPoint: object.position);
    final vertices = rotatedVertices
        .map((v) => project(v, focalLength, size.width, size.height))
        .toList();
    for (final face in object.faces) {
      if (face.isEmpty) {
        continue;
      }
      if (_isFrontFace(face, rotatedVertices)) {
        final path = Path();
        path.moveTo(vertices[face[0]].x, vertices[face[0]].y);
        for (int i = 1; i < face.length; i++) {
          path.lineTo(vertices[face[i]].x, vertices[face[i]].y);
        }
        path.lineTo(vertices[face[0]].x, vertices[face[0]].y);
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  bool _isFrontFace(List<int> face, List<Point3D> vertices) {
    final p1 = vertices[face[0]];
    final p2 = vertices[face[1]];
    final p3 = vertices[face[2]];

    final v1 = Point3D(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
    final v2 = Point3D(p3.x - p1.x, p3.y - p1.y, p3.z - p1.z);

    final n = Point3D(v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x);
    return -p1.x * n.x + -p1.y * n.y + -p1.z * n.z < 0;
  }

  Point2D project(
      Point3D point3d, double focalLength, double width, double height) {
    final x = point3d.x * (focalLength / point3d.z) + width * 0.5;
    final y = point3d.y * (focalLength / point3d.z) + height * 0.5;
    return Point2D(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  List<Point3D> _rotate(
    List<Point3D> points, {
    required Rotation rotation,
    required Point3D aroundPoint,
  }) {
    final xCos = cos(rotation.x);
    final xSin = sin(rotation.x);
    final yCos = cos(rotation.y);
    final ySin = sin(rotation.y);
    final zCos = cos(rotation.z);
    final zSin = sin(rotation.z);

    return points.map((point) {
      final px = point.x - aroundPoint.x;
      final py = point.y - aroundPoint.y;
      final pz = point.z - aroundPoint.z;

      final nx = zCos * yCos * px +
          (zCos * ySin * xSin * py - zSin * xCos * py) +
          (zCos * ySin * xCos * pz + zSin * xSin * pz);
      final ny = zSin * yCos * px +
          (zSin * ySin * xSin * py + zCos * xCos * py) +
          (zSin * ySin * xCos * pz - zCos * xSin * pz);
      final nz = -ySin * px + yCos * xSin * py + yCos * xCos * pz;

      return Point3D(
          nx + aroundPoint.x, ny + aroundPoint.y, nz + aroundPoint.z);
    }).toList(growable: false);
  }
}
