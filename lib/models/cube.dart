import 'models.dart';

class Cube extends Object3D<Cube> {
  @override
  final Point3D position;
  @override
  final Rotation rotation;
  late final List<Face> _faces;
  final double _size;

  @override
  List<Face> get faces => _faces;

  Cube({
    required this.position,
    required double size,
    this.rotation = const Rotation(0, 0, 0),
  }) : _size = size {
    final x = position.x;
    final y = position.y;
    final z = position.z;
    final vertices = [
      Point3D(x - size * 0.5, y - size * 0.5, z - size * 0.5),
      Point3D(x + size * 0.5, y - size * 0.5, z - size * 0.5),
      Point3D(x + size * 0.5, y + size * 0.5, z - size * 0.5),
      Point3D(x - size * 0.5, y + size * 0.5, z - size * 0.5),
      Point3D(x - size * 0.5, y - size * 0.5, z + size * 0.5),
      Point3D(x + size * 0.5, y - size * 0.5, z + size * 0.5),
      Point3D(x + size * 0.5, y + size * 0.5, z + size * 0.5),
      Point3D(x - size * 0.5, y + size * 0.5, z + size * 0.5),
    ];
    _faces = [
      Face([vertices[0], vertices[1], vertices[2], vertices[3]]),
      Face([vertices[0], vertices[4], vertices[5], vertices[1]]),
      Face([vertices[1], vertices[5], vertices[6], vertices[2]]),
      Face([vertices[3], vertices[2], vertices[6], vertices[7]]),
      Face([vertices[0], vertices[3], vertices[7], vertices[4]]),
      Face([vertices[4], vertices[7], vertices[6], vertices[5]]),
    ];
  }

  @override
  Cube copyWith({Point3D? position, Rotation? rotation, double? size}) {
    return Cube(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      size: size ?? _size,
    );
  }
}
