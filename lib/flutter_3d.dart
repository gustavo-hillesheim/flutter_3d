library flutter_3d;

import 'dart:math';

import 'package:flutter/material.dart';

class Renderer3d extends StatelessWidget {
  final double focalLength;
  final double? width;
  final double? height;
  final Cube cube;

  const Renderer3d({
    required this.focalLength,
    required this.cube,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 10),
        ),
        child: CustomPaint(
          size: Size(
            width ?? constraints.maxWidth,
            height ?? constraints.maxHeight,
          ),
          painter: Painter3d(focalLength: focalLength, cube: cube),
        ),
      );
    });
  }
}

class Painter3d extends CustomPainter {
  final double focalLength;
  final Cube cube;

  Painter3d({
    required this.focalLength,
    required this.cube,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()..color = Colors.blue;

    final vertices = cube.vertices
        .map((v) => project(v, focalLength, size.width, size.height))
        .toList();
    for (final face in cube.faces) {
      if (_isFrontFace(face, cube.vertices)) {
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

  bool _isFrontFace(List<int> face, List<Point3d> vertices) {
    final p1 = vertices[face[0]];
    final p2 = vertices[face[1]];
    final p3 = vertices[face[2]];

    final v1 = Point3d(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
    final v2 = Point3d(p3.x - p1.x, p3.y - p1.y, p3.z - p1.z);

    final n = Point3d(v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x);
    return -p1.x * n.x + -p1.y * n.y + -p1.z * n.z < 0;
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

  const Point2d(this.x, this.y);
}

class Point3d {
  final double x;
  final double y;
  final double z;

  const Point3d(this.x, this.y, this.z);
}

class Rotation {
  final double x;
  final double y;

  const Rotation(this.x, this.y);
}

class Cube {
  final Point3d position;
  final double size;
  List<Point3d> _vertices = [];
  final List<List<int>> faces;

  List<Point3d> get vertices => _vertices;

  Cube({
    required this.position,
    required this.size,
    Rotation initialRotation = const Rotation(0, 0),
  }) : faces = [
          [0, 1, 2, 3],
          [0, 4, 5, 1],
          [1, 5, 6, 2],
          [3, 2, 6, 7],
          [0, 3, 7, 4],
          [4, 7, 6, 5],
        ] {
    final x = position.x;
    final y = position.y;
    final z = position.z;
    _vertices = [
      Point3d(x - size * 0.5, y - size * 0.5, z - size * 0.5),
      Point3d(x + size * 0.5, y - size * 0.5, z - size * 0.5),
      Point3d(x + size * 0.5, y + size * 0.5, z - size * 0.5),
      Point3d(x - size * 0.5, y + size * 0.5, z - size * 0.5),
      Point3d(x - size * 0.5, y - size * 0.5, z + size * 0.5),
      Point3d(x + size * 0.5, y - size * 0.5, z + size * 0.5),
      Point3d(x + size * 0.5, y + size * 0.5, z + size * 0.5),
      Point3d(x - size * 0.5, y + size * 0.5, z + size * 0.5),
    ];
    _vertices =
        _rotateY(_vertices, rotation: initialRotation.y, origin: position);
    _vertices =
        _rotateX(_vertices, rotation: initialRotation.x, origin: position);
  }

  void rotateX(double rotation) {
    _vertices = _rotateX(vertices, rotation: rotation, origin: position);
  }

  void rotateY(double rotation) {
    _vertices = _rotateY(vertices, rotation: rotation, origin: position);
  }
}

List<Point3d> _rotateX(
  List<Point3d> points, {
  required double rotation,
  required Point3d origin,
}) {
  final cosine = cos(rotation);
  final sine = sin(rotation);
  return points.map((p) {
    final y = (p.y - origin.y) * cosine - (p.z - origin.z) * sine;
    final z = (p.y - origin.y) * sine + (p.z - origin.z) * cosine;
    return Point3d(p.x, y + origin.y, z + origin.z);
  }).toList(growable: false);
}

List<Point3d> _rotateY(
  List<Point3d> points, {
  required double rotation,
  required Point3d origin,
}) {
  final cosine = cos(rotation);
  final sine = sin(rotation);
  return points.map((p) {
    final x = (p.z - origin.z) * sine + (p.x - origin.x) * cosine;
    final z = (p.z - origin.z) * cosine - (p.x - origin.x) * sine;
    return Point3d(x + origin.x, p.y, z + origin.z);
  }).toList(growable: false);
}
