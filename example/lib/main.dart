import 'dart:async';

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
  final cube = Cube(
    x: 0,
    y: 0,
    z: 400,
    size: 250,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            cube.rotateX(details.delta.dy * 0.01);
            cube.rotateY(details.delta.dx * -0.01);
          });
        },
        child: Center(
          child: Renderer3d(
            width: 300,
            height: 300,
            focalLength: 200,
            cube: cube,
          ),
        ),
      ),
    );
  }
}
