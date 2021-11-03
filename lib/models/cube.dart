import 'models.dart';

class Cube extends Object3D<Cube> {
  @override
  final Point3D position;
  @override
  final Rotation rotation;
  @override
  final List<List<int>> faces;
  final double size;
  List<Point3D> _vertices = [];

  @override
  List<Point3D> get vertices => _vertices;

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
      Point3D(x - size * 0.5, y - size * 0.5, z - size * 0.5),
      Point3D(x + size * 0.5, y - size * 0.5, z - size * 0.5),
      Point3D(x + size * 0.5, y + size * 0.5, z - size * 0.5),
      Point3D(x - size * 0.5, y + size * 0.5, z - size * 0.5),
      Point3D(x - size * 0.5, y - size * 0.5, z + size * 0.5),
      Point3D(x + size * 0.5, y - size * 0.5, z + size * 0.5),
      Point3D(x + size * 0.5, y + size * 0.5, z + size * 0.5),
      Point3D(x - size * 0.5, y + size * 0.5, z + size * 0.5),
    ];
  }

  @override
  Cube copyWith({Point3D? position, Rotation? rotation, double? size}) {
    return Cube(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
    );
  }
}
