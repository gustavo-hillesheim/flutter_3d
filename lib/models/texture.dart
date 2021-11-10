import 'dart:ui';

abstract class Texture {
  List<Paint> get paints;
}

class FlatColorTexture implements Texture {
  final Paint _paint;

  FlatColorTexture(Color color) : _paint = (Paint()..color = color);

  @override
  List<Paint> get paints => [_paint];
}

class BorderedTexture implements Texture {
  @override
  final List<Paint> paints;

  BorderedTexture({required Color fillColor, required Color borderColor})
      : paints = [
          Paint()
            ..color = fillColor
            ..style = PaintingStyle.fill,
          Paint()
            ..color = borderColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        ];
}
