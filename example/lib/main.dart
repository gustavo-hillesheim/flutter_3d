import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_3d/flutter_3d.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _cube = Cube(
    position: const Point3d(0, 0, 400),
    initialRotation: const Rotation(math.pi * 0.20, math.pi * 0.25),
    size: 250,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _cube.rotateX(details.delta.dy * 0.01);
            _cube.rotateY(details.delta.dx * -0.01);
          });
        },
        child: Center(
          child: Renderer3d(
            width: 300,
            height: 300,
            focalLength: 200,
            cube: _cube,
          ),
        ),
      ),
    );
  }
}
