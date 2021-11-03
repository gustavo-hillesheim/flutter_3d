import 'models.dart';

abstract class Object3D<R extends Object3D<dynamic>> {
  Point3D get position;
  Rotation get rotation;
  List<Face> get faces;

  R copyWith({Point3D? position, Rotation? rotation});

  R at({double? x, double? y, double? z}) {
    return copyWith(
      position: position.copyWith(x: x, y: y, z: z),
    );
  }

  R rotated({double? x, double? y, double? z}) {
    return copyWith(
      rotation: rotation.copyWith(x: x, y: y, z: z),
    );
  }
}
