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
  var cube = Cube(
    position: const Point3d(0, 0, 400),
    size: 250,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Renderer3d(
                  focalLength: 200,
                  cube: cube,
                ),
              ),
            ),
            BottomCard(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Position'),
                          _inputRow(
                            'X',
                            cube.position.x,
                            10,
                            (value) => setState(() {
                              cube = cube.at(x: value);
                            }),
                          ),
                          const SizedBox(height: 8),
                          _inputRow(
                            'Y',
                            cube.position.y,
                            10,
                            (value) => setState(() {
                              cube = cube.at(y: value);
                            }),
                          ),
                          const SizedBox(height: 8),
                          _inputRow(
                            'Z',
                            cube.position.z,
                            10,
                            (value) => setState(() {
                              cube = cube.at(z: value);
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Rotation'),
                          _inputRow(
                            'X',
                            cube.rotation.x,
                            0.1,
                            (value) => setState(() {
                              cube = cube.rotated(x: value);
                            }),
                          ),
                          const SizedBox(height: 8),
                          _inputRow(
                            'Y',
                            cube.rotation.y,
                            0.1,
                            (value) => setState(() {
                              cube = cube.rotated(y: value);
                            }),
                          ),
                          const SizedBox(height: 8),
                          _inputRow(
                            'Z',
                            cube.rotation.z,
                            0.1,
                            (value) => setState(() {
                              cube = cube.rotated(z: value);
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputRow(
    String label,
    double initialValue,
    double panMultiplier,
    ValueChanged<double> onChange,
  ) {
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                onChange(details.delta.dx * panMultiplier + initialValue);
              },
              child: TextFormField(
                controller: TextEditingController(
                  text: initialValue.toStringAsFixed(2),
                ),
                onChanged: (v) => onChange(double.tryParse(v) ?? 0),
                keyboardType: TextInputType.number,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomCard extends StatelessWidget {
  final Color color;
  final Widget child;

  const BottomCard({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: child,
    );
  }
}
