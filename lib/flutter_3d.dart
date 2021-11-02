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
      return CustomPaint(
        size: Size(
          width ?? constraints.maxWidth,
          height ?? constraints.maxHeight,
        ),
        painter: Painter3d(focalLength: focalLength, cube: cube),
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
      ..color = Colors.white
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()..color = Colors.blue;

    final rotatedVertices = _rotate(cube.vertices,
        rotation: cube.rotation, aroundPoint: cube.position);
    final vertices = rotatedVertices
        .map((v) => project(v, focalLength, size.width, size.height))
        .toList();
    for (final face in cube.faces) {
      if (_isFrontFace(face, rotatedVertices)) {
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

  Point3d copyWith({double? x, double? y, double? z}) {
    return Point3d(x ?? this.x, y ?? this.y, z ?? this.z);
  }
}

class Rotation {
  final double x;
  final double y;
  final double z;

  const Rotation(this.x, this.y, this.z);

  Rotation copyWith({double? x, double? y, double? z}) {
    return Rotation(x ?? this.x, y ?? this.y, z ?? this.z);
  }
}

class Cube {
  final Point3d position;
  final double size;
  final Rotation rotation;
  List<Point3d> _vertices = [];
  final List<List<int>> faces;

  List<Point3d> get vertices => _vertices;

  Cube({
    required this.position,
    required this.size,
    this.rotation = const Rotation(0, 0, 0),
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
  }

  Cube at({double? x, double? y, double? z}) {
    return copyWith(
      position: position.copyWith(x: x, y: y, z: z),
      rotation: rotation,
      size: size,
    );
  }

  Cube rotated({double? x, double? y, double? z}) {
    return copyWith(
      position: position,
      rotation: rotation.copyWith(x: x, y: y, z: z),
      size: size,
    );
  }

  Cube copyWith({Point3d? position, Rotation? rotation, double? size}) {
    return Cube(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
    );
  }
}

List<Point3d> _rotate(
  List<Point3d> points, {
  required Rotation rotation,
  required Point3d aroundPoint,
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

    return Point3d(nx + aroundPoint.x, ny + aroundPoint.y, nz + aroundPoint.z);
  }).toList(growable: false);
}
