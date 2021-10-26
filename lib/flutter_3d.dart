library flutter_3d;

import 'dart:math';

import 'package:flutter/material.dart';

class Renderer3d extends StatelessWidget {
  final double height;
  final double width;
  final double focalLength;
  final Cube cube;

  Renderer3d({
    required this.height,
    required this.width,
    required this.focalLength,
    required this.cube,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: Painter3d(
            height: height, width: width, focalLength: focalLength, cube: cube),
      ),
    );
  }
}

class Painter3d extends CustomPainter {
  final double width;
  final double height;
  final double focalLength;
  final Cube cube;

  Painter3d({
    required this.width,
    required this.height,
    required this.focalLength,
    required this.cube,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()..color = Colors.blue;

    final vertices = cube.vertices
        .map((v) => project(v, focalLength, width, height))
        .toList();
    for (final face in cube.faces) {
      final p1 = cube.vertices[face[0]];
      final p2 = cube.vertices[face[1]];
      final p3 = cube.vertices[face[2]];

      final v1 = Point3d(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
      final v2 = Point3d(p3.x - p1.x, p3.y - p1.y, p3.z - p1.z);

      final n = Point3d(v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z,
          v1.x * v2.y - v1.y * v2.x);

      if (-p1.x * n.x + -p1.y * n.y + -p1.z * n.z < 0) {
        final path = Path();
        path.moveTo(vertices[face[0]].x, vertices[face[0]].y);
        path.lineTo(vertices[face[1]].x, vertices[face[1]].y);
        path.lineTo(vertices[face[2]].x, vertices[face[2]].y);
        path.lineTo(vertices[face[3]].x, vertices[face[3]].y);
        path.lineTo(vertices[face[0]].x, vertices[face[0]].y);
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  Point2d project(
      Point3d point3d, double focalLength, double width, double height) {
    final x = point3d.x * (focalLength / point3d.z) + width * 0.5;
    final y = point3d.y * (focalLength / point3d.z) + height * 0.5;
    return Point2d(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Point2d {
  final double x;
  final double y;

  Point2d(this.x, this.y);
}

class Point3d {
  final double x;
  final double y;
  final double z;

  Point3d(this.x, this.y, this.z);
}

class Cube {
  final double x;
  final double y;
  final double z;
  late final double size;
  late final List<Point3d> vertices;
  late final List<List<int>> faces;

  Cube({
    required this.x,
    required this.y,
    required this.z,
    required double size,
  }) {
    size *= 0.5;
    this.size = size;
    vertices = [
      Point3d(x - size, y - size, z - size),
      Point3d(x + size, y - size, z - size),
      Point3d(x + size, y + size, z - size),
      Point3d(x - size, y + size, z - size),
      Point3d(x - size, y - size, z + size),
      Point3d(x + size, y - size, z + size),
      Point3d(x + size, y + size, z + size),
      Point3d(x - size, y + size, z + size),
    ];
    faces = [
      [0, 1, 2, 3],
      [0, 4, 5, 1],
      [1, 5, 6, 2],
      [3, 2, 6, 7],
      [0, 3, 7, 4],
      [4, 7, 6, 5],
    ];
  }

  void rotateX(double radian) {
    final cosine = cos(radian);
    final sine = sin(radian);
    for (var index = vertices.length - 1; index > -1; --index) {
      final p = vertices[index];
      final y = (p.y - this.y) * cosine - (p.z - this.z) * sine;
      final z = (p.y - this.y) * sine + (p.z - this.z) * cosine;
      vertices[index] = Point3d(p.x, y + this.y, z + this.z);
    }
  }

  void rotateY(double radian) {
    final cosine = cos(radian);
    final sine = sin(radian);
    for (var index = vertices.length - 1; index > -1; --index) {
      final p = vertices[index];
      final x = (p.z - this.z) * sine + (p.x - this.x) * cosine;
      final z = (p.z - this.z) * cosine - (p.x - this.x) * sine;
      vertices[index] = Point3d(x + this.x, p.y, z + this.z);
    }
  }
}
