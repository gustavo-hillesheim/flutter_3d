import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_3d/flutter_3d.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Flutter3dExample(),
      ),
    );
  }
}

class Flutter3dExample extends StatefulWidget {
  @override
  State<Flutter3dExample> createState() => _Flutter3dExampleState();
}

class _Flutter3dExampleState extends State<Flutter3dExample> {
  var cube = Cube(
    position: const Point3d(0, 0, 1000),
    rotation: const Rotation(math.pi * 0.25, math.pi * 0.20, math.pi * 0.19),
    size: 250,
  );

  @override
  Widget build(BuildContext context) {
    final cubeRenderer = Expanded(
      child: Center(
        child: Renderer3d(
          focalLength: 500,
          cube: cube,
        ),
      ),
    );
    final queryData = MediaQuery.of(context);
    final aspectRatio = queryData.size.height / queryData.size.width;

    return aspectRatio > 1
        ? Column(
            children: [
              cubeRenderer,
              _positionAndRotationInputs(aspectRatio),
            ],
          )
        : Row(
            children: [
              cubeRenderer,
              _positionAndRotationInputs(aspectRatio),
            ],
          );
  }

  Widget _positionAndRotationInputs(double aspectRatio) {
    if (aspectRatio > 1) {
      return DirectionalCard(
        color: Colors.white,
        direction: TraversalDirection.up,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _positionInputs(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _rotationInputs(),
              ),
            ],
          ),
        ),
      );
    } else {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        child: DirectionalCard(
          color: Colors.white,
          direction: TraversalDirection.left,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox.expand(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _positionInputs(),
                    const SizedBox(height: 16),
                    _rotationInputs(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _positionInputs() => Column(
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
      );

  Widget _rotationInputs() => Column(
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
      );

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
            child: SlidableNumberField(
              initialValue: initialValue,
              valueMultiplier: panMultiplier,
              onChange: onChange,
            ),
          ),
        ],
      ),
    );
  }
}

class SlidableNumberField extends StatefulWidget {
  final double initialValue;
  final double valueMultiplier;
  final ValueChanged<double> onChange;

  const SlidableNumberField({
    Key? key,
    required this.initialValue,
    required this.valueMultiplier,
    required this.onChange,
  }) : super(key: key);

  @override
  _SlidableNumberFieldState createState() => _SlidableNumberFieldState();
}

class _SlidableNumberFieldState extends State<SlidableNumberField> {
  late Timer _timer;
  double _initialPan = 0;
  double _finalPan = 0;
  TextEditingController? _textController;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _initialPan = 0;
        _finalPan = 0;
      }
    });
    _timer = Timer.periodic(const Duration(milliseconds: 10), _updateValue);
    _textController = TextEditingController(
      text: widget.initialValue.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _focusNode.dispose();
    _textController?.dispose();
    super.dispose();
  }

  void _updateValue(_) {
    final difference = (_finalPan - _initialPan) * 0.01;
    final newValue = difference * widget.valueMultiplier + widget.initialValue;
    widget.onChange(newValue);
    _textController?.text = newValue.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      controller: _textController,
      focusNode: _focusNode,
      onChanged: (v) {
        final parsedValue = double.tryParse(v);
        if (parsedValue != null) {
          widget.onChange(parsedValue);
        }
      },
      keyboardType: TextInputType.number,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _focusNode.requestFocus();
      },
      onHorizontalDragStart: (details) {
        _initialPan = details.localPosition.dx;
      },
      onHorizontalDragUpdate: (details) {
        _finalPan = details.localPosition.dx;
      },
      onHorizontalDragEnd: (_) {
        _initialPan = 0;
        _finalPan = 0;
      },
      child: IgnorePointer(
        child: textField,
      ),
    );
  }
}

class DirectionalCard extends StatelessWidget {
  final Color color;
  final Widget child;
  final TraversalDirection direction;

  const DirectionalCard({
    Key? key,
    required this.color,
    required this.child,
    required this.direction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: _borderRadius(),
      ),
      child: child,
    );
  }

  BorderRadius _borderRadius() {
    const radius = Radius.circular(16);
    switch (direction) {
      case TraversalDirection.up:
        return const BorderRadius.vertical(top: radius);
      case TraversalDirection.down:
        return const BorderRadius.vertical(bottom: radius);
      case TraversalDirection.left:
        return const BorderRadius.horizontal(left: radius);
      case TraversalDirection.right:
        return const BorderRadius.horizontal(right: radius);
    }
  }
}
