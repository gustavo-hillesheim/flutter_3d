class Rotation {
  final double x;
  final double y;
  final double z;

  const Rotation(this.x, this.y, this.z);

  Rotation copyWith({double? x, double? y, double? z}) {
    return Rotation(x ?? this.x, y ?? this.y, z ?? this.z);
  }
}
