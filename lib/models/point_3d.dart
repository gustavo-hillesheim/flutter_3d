class Point3D {
  final double x;
  final double y;
  final double z;

  const Point3D(this.x, this.y, this.z);

  Point3D copyWith({double? x, double? y, double? z}) {
    return Point3D(x ?? this.x, y ?? this.y, z ?? this.z);
  }
}
