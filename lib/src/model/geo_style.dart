import 'package:quiver/core.dart';

class GeoStyle {
  String? id;
  LineStyle? lineStyle;
  PolyStyle? polyStyle;
  IconStyle? iconStyle;
  LabelStyle? labelStyle;
  BalloonStyle? balloonStyle;
  // ListStyle? listStyle;
  GeoStyle({
    this.id,
    this.lineStyle,
    this.polyStyle,
    this.iconStyle,
    this.labelStyle,
    this.balloonStyle,
    // this.listStyle,
  });
}

enum ColorMode {
  normal('normal'),
  random('random');

  const ColorMode(this.value);

  final String value;
}

abstract class ColorStyle {
  int? color;
  ColorMode? colorMode;
}

class LineStyle extends ColorStyle {
  double? width;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is LineStyle) {
      return  other.color == super.color &&
          other.colorMode == super.colorMode &&
          other.width == width;
    }

    return false;
  }

  @override
  String toString() => "LineStyle[${[width].join(",")}]";

  @override
  int get hashCode => hashObjects([
    width
  ]);
}

class PolyStyle extends ColorStyle {
  int? fill;
  int? outline;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is PolyStyle) {
      return  other.color == super.color &&
              other.colorMode == super.colorMode &&
              other.fill == fill &&
              other.outline == outline;
    }

    return false;
  }

  @override
  String toString() => "PolyStyle[${[
    color, colorMode, fill, outline,].join(",")}]";

  @override
  int get hashCode => hashObjects([
    color,
    colorMode,
    fill,
    outline,
  ]);
}

enum HotspotUnits {
  /// Fraction
  fraction('fraction'),
  /// Pixels offset from left or bottom
  pixels('pixels'),
  /// Pixels offset from right or top
  insetPixels('insetPixels');

  const HotspotUnits(this.value);

  final String value;
}

class IconStyle extends ColorStyle {
  String? iconUrl;
  double? scale;
  double? heading;
  num? x;
  num? y;
  HotspotUnits? xunit;
  HotspotUnits? yunit;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is IconStyle) {
      return   other.color == super.color &&
          other.colorMode == super.colorMode &&
          other.iconUrl == iconUrl &&
              other.scale == scale &&
              other.heading == heading &&
              other.x == x &&
              other.y == y &&
              other.xunit == xunit &&
              other.yunit == yunit;
    }

    return false;
  }

  @override
  String toString() => "IconStyle[${[
    iconUrl, scale, heading, x, y, xunit, yunit,].join(",")}]";

  @override
  int get hashCode => hashObjects([
    iconUrl,
    scale,
    heading,
    x,
    y,
    xunit,
    yunit,
  ]);
}

class LabelStyle extends ColorStyle {
  double? scale;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is LabelStyle) {
      return   other.color == super.color &&
          other.colorMode == super.colorMode &&
          other.scale == scale;
    }

    return false;
  }

  @override
  String toString() => "LabelStyle[${[scale].join(",")}]";

  @override
  int get hashCode => hashObjects([
    scale,
  ]);
}

class BalloonStyle extends ColorStyle {
  int? bgColor;
  int? textColor = 0xff000000;
  String text = '';
  bool show = true;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is BalloonStyle) {
      return   other.color == super.color &&
          other.colorMode == super.colorMode &&
          other.bgColor == bgColor &&
              other.textColor == textColor &&
              other.text == text &&
              other.show == show;
    }

    return false;
  }

  @override
  String toString() => "BalloonStyle[${[
    bgColor, textColor, text, show].join(",")}]";

  @override
  int get hashCode => hashObjects([
    bgColor,
    textColor,
    text,
    show,
  ]);
}

class ListStyle {
  ListStyle() {
    throw UnimplementedError();
  }
}
