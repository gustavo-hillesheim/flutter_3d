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
    position: const Point3D(0, 0, 1000),
    rotation: const Rotation(math.pi * 0.25, math.pi * 0.20, math.pi * 0.19),
    size: 250,
  );

  @override
  Widget build(BuildContext context) {
    final cubeRenderer = Expanded(
      child: Center(
        child: Object3DRenderer(
          focalLength: 500,
          object: cube,
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
            key: 'position-x',
            label: 'X',
            initialValue: cube.position.x,
            panMultiplier: 10,
            onChange: (value) => setState(() {
              cube = cube.at(x: value);
            }),
          ),
          const SizedBox(height: 8),
          _inputRow(
            key: 'position-y',
            label: 'Y',
            initialValue: cube.position.y,
            panMultiplier: 10,
            onChange: (value) => setState(() {
              cube = cube.at(y: value);
            }),
          ),
          const SizedBox(height: 8),
          _inputRow(
            key: 'position-z',
            label: 'Z',
            initialValue: cube.position.z,
            panMultiplier: 10,
            onChange: (value) => setState(() {
              cube = cube.at(z: value);
            }),
          ),
        ],
      );

  Widget _rotationInputs() => Column(
        children: [
          const Text('Rotation'),
          _inputRow(
            key: 'rotation-x',
            label: 'X',
            initialValue: cube.rotation.x,
            panMultiplier: 0.1,
            onChange: (value) => setState(() {
              cube = cube.rotated(x: value);
            }),
          ),
          const SizedBox(height: 8),
          _inputRow(
            key: 'rotation-y',
            label: 'Y',
            initialValue: cube.rotation.y,
            panMultiplier: 0.1,
            onChange: (value) => setState(() {
              cube = cube.rotated(y: value);
            }),
          ),
          const SizedBox(height: 8),
          _inputRow(
            key: 'rotation-z',
            label: 'Z',
            initialValue: cube.rotation.z,
            panMultiplier: 0.1,
            onChange: (value) => setState(() {
              cube = cube.rotated(z: value);
            }),
          ),
        ],
      );

  Widget _inputRow({
    required String key,
    required String label,
    required double initialValue,
    required double panMultiplier,
    required ValueChanged<double> onChange,
  }) {
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label),
          const SizedBox(width: 8),
          Expanded(
            child: SlidableNumberField(
              key: ValueKey(key),
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
  Timer? _timer;
  double _initialPan = 0;
  double _finalPan = 0;
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _initialPan = 0;
        _finalPan = 0;
      }
      setState(() {});
    });
    _textController.text = widget.initialValue.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _createTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(milliseconds: 10), _updateValue);
  }

  void _updateValue(_) {
    final difference = (_finalPan - _initialPan) * 0.01;
    final newValue = difference * widget.valueMultiplier + widget.initialValue;
    widget.onChange(newValue);
    _textController.text = newValue.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      key: widget.key,
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
        _createTimer();
      },
      onHorizontalDragUpdate: (details) {
        _finalPan = details.localPosition.dx;
      },
      onHorizontalDragEnd: (_) {
        _initialPan = 0;
        _finalPan = 0;
        if (_timer != null && _timer!.isActive) {
          _timer!.cancel();
        }
      },
      child: IgnorePointer(
        ignoring: !_focusNode.hasFocus,
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
