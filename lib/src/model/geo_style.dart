import 'package:quiver/core.dart';

/// docs are copied from a CC BY 4.0 work:
/// https://developers.google.com/kml/documentation/kmlreference#folder
///
/// implemented the style element of kml,
/// Please note that gpx has no style information
class GeoStyle {
  /// a distinct id of a style, which makes it possible to reuse styles
  /// unique in a kml document
  String? id;

  /// see `LineStyle`
  LineStyle? lineStyle;

  /// see `PolyStyle`
  PolyStyle? polyStyle;

  /// see `IconStyle`
  IconStyle? iconStyle;

  /// see ` LabelStyle`
  LabelStyle? labelStyle;

  /// see `BalloonStyle`
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

/// see `ColorStyle.colorMode`
enum ColorMode {
  normal('normal'),
  random('random');

  const ColorMode(this.value);

  final String value;
}

/// This is an abstract element and cannot be used directly in a KML file.
/// It provides elements for specifying the color and color mode of extended
/// style types.
abstract class ColorStyle {
  /// Color and opacity (alpha) values are expressed in hexadecimal notation.
  /// The range of values for any one color is 0 to 255 (00 to ff). For alpha,
  /// 00 is fully transparent and ff is fully opaque. The order of expression
  /// is aabbggrr, where aa=alpha (00 to ff); bb=blue (00 to ff); gg=green
  /// (00 to ff); rr=red (00 to ff). For example, if you want to apply a blue
  /// color with 50 percent opacity to an overlay, you would specify the
  /// following: <color>7fff0000</color>, where alpha=0x7f, blue=0xff,
  /// green=0x00, and red=0x00.
  int? color;

  /// Values for <colorMode> are normal (no effect) and random. A value of
  /// random applies a random linear scale to the base <color> as follows.
  ///
  // * To achieve a truly random selection of colors, specify a base <color>
  //   of white (ffffffff).
  // * If you specify a single color component (for example, a value of
  //   ff0000ff for red), random color values for that one component (red) will
  //   be selected. In this case, the values would range from 00 (black) to ff
  //   (full red).
  // * If you specify values for two or for all three color components, a
  //   random linear scale is applied to each color component, with results
  //   ranging from black to the maximum values specified for each component.
  // * The opacity of a color comes from the alpha component of <color> and
  //   is never randomized.

  ColorMode? colorMode;
}

/// Specifies the drawing style (color, color mode, and line width) for all
/// line geometry. Line geometry includes the outlines of outlined polygons and
/// the extruded "tether" of Placemark icons (if extrusion is enabled).
///
/// Some extended attributed are not yet implemented.
class LineStyle extends ColorStyle {
  /// Width of the line, in pixels.
  double? width;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is LineStyle) {
      return other.color == super.color &&
          other.colorMode == super.colorMode &&
          other.width == width;
    }

    return false;
  }

  @override
  String toString() => "LineStyle[${[color, colorMode, width].join(",")}]";

  @override
  int get hashCode => hashObjects([color, colorMode, width]);
}

/// Specifies the drawing style for all polygons, including polygon extrusions
/// (which look like the walls of buildings) and line extrusions (which look
/// like solid fences).
class PolyStyle extends ColorStyle {
  /// Boolean value. Specifies whether to fill the polygon.
  int? fill;

  /// Boolean value. Specifies whether to outline the polygon.
  /// Polygon outlines use the current LineStyle.
  int? outline;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is PolyStyle) {
      return other.color == super.color &&
          other.colorMode == super.colorMode &&
          other.fill == fill &&
          other.outline == outline;
    }

    return false;
  }

  @override
  String toString() => "PolyStyle[${[
        color,
        colorMode,
        color,
        colorMode,
        fill,
        outline,
      ].join(",")}]";

  @override
  int get hashCode => hashObjects([
        color,
        colorMode,
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

/// Specifies how icons for point Placemarks are drawn, both in the Places panel
/// and in the 3D viewer of Google Earth. The <Icon> element specifies the icon
/// image. The <scale> element specifies the x, y scaling of the icon. The color
/// specified in the <color> element of <IconStyle> is blended with the color of
/// the <Icon>.
class IconStyle extends ColorStyle {
  /// An HTTP address or a local file specification used to load an icon.
  /// It is a <href> element nested in <Icon>.
  String? iconUrl;

  /// Resizes scale of the icon.
  double? scale;

  /// Direction (that is, North, South, East, West), in degrees.
  /// Default=0 (North). (See diagram.) Values range from 0 to 360 degrees.
  double? heading;

  /// the following 4 filed are attributes of hotSpot element, for example:
  /// <hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction">

  /// x - Either the number of pixels, a fractional component of the icon, or a
  /// pixel inset indicating the x component of a point on the icon.
  num? x;

  /// y - Either the number of pixels, a fractional component of the icon, or a
  /// pixel inset indicating the y component of a point on the icon.
  num? y;

  /// xunits - Units in which the x value is specified. A value of fraction
  /// indicates the x value is a fraction of the icon. A value of pixels
  /// indicates the x value in pixels. A value of insetPixels indicates the
  /// indent from the right edge of the icon.
  HotspotUnits? xunit;

  /// yunits - Units in which the y value is specified. A value of fraction
  /// indicates the y value is a fraction of the icon. A value of pixels
  /// indicates the y value in pixels. A value of insetPixels indicates the
  /// indent from the top edge of the icon.
  HotspotUnits? yunit;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is IconStyle) {
      return other.color == super.color &&
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
        color,
        colorMode,
        iconUrl,
        scale,
        heading,
        x,
        y,
        xunit,
        yunit,
      ].join(",")}]";

  @override
  int get hashCode => hashObjects([
        color,
        colorMode,
        iconUrl,
        scale,
        heading,
        x,
        y,
        xunit,
        yunit,
      ]);
}

/// Specifies how the <name> of a Feature is drawn in the 3D viewer. A custom
/// color, color mode, and scale for the label (name) can be specified.
class LabelStyle extends ColorStyle {
  /// Resizes scale of the label.
  double? scale;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is LabelStyle) {
      return other.color == super.color &&
          other.colorMode == super.colorMode &&
          other.scale == scale;
    }

    return false;
  }

  @override
  String toString() => "LabelStyle[${[color, colorMode, scale].join(",")}]";

  @override
  int get hashCode => hashObjects([
        color,
        colorMode,
        scale,
      ]);
}

/// Specifies how the description balloon for placemarks is drawn.
/// The <bgColor>, if specified, is used as the background color of the balloon.
/// See <Feature> for a diagram illustrating how the default description balloon
/// appears in Google Earth.
class BalloonStyle {
  /// Background color of the balloon (optional). Color and opacity (alpha)
  /// values are expressed in hexadecimal notation. The range of values for any
  /// one color is 0 to 255 (00 to ff). The order of expression is aabbggrr,
  /// where aa=alpha (00 to ff); bb=blue (00 to ff); gg=green (00 to ff); rr=red
  /// (00 to ff). For alpha, 00 is fully transparent and ff is fully opaque. For
  /// example, if you want to apply a blue color with 50 percent opacity to an
  /// overlay, you would specify the following: <bgColor>7fff0000</bgColor>,
  /// where alpha=0x7f, blue=0xff, green=0x00, and red=0x00. The default is
  /// opaque white (ffffffff).
  int? bgColor;

  /// Foreground color for text. The default is black (ff000000).
  int? textColor = 0xff000000;

  /// Text displayed in the balloon. If no text is specified, Google Earth
  /// draws the default balloon (with the Feature <name> in boldface, the
  /// Feature <description>, links for driving directions, a white background,
  /// and a tail that is attached to the point coordinates of the Feature, if
  /// specified).
  ///
  /// You can add entities to the <text> tag using the following format to
  /// refer to a child element of Feature: name, description, address,
  /// id, Snippet. Google Earth looks in the current Feature for the
  /// corresponding string entity and substitutes that information in the
  /// balloon. To include To here - From here driving directions in the balloon,
  /// use the geDirections tag. To prevent the driving directions links from
  /// appearing in a balloon, include the <text> element with some content, or
  /// with description to substitute the basic Feature <description>.
  ///
  /// For example, in the following KML excerpt, name and description
  /// fields will be replaced by the <name> and <description> fields found in
  /// the Feature elements that use this BalloonStyle:
  String text = '';

  /// If <displayMode> is default, Google Earth uses the information
  /// supplied in <text> to create a balloon . If <displayMode> is hide,
  /// Google Earth does not display the balloon. In Google Earth, clicking
  /// the List View icon for a Placemark whose balloon's <displayMode> is
  /// hide causes Google Earth to fly to the Placemark.
  bool show = true;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is BalloonStyle) {
      return other.bgColor == bgColor &&
          other.textColor == textColor &&
          other.text == text &&
          other.show == show;
    }

    return false;
  }

  @override
  String toString() =>
      "BalloonStyle[${[bgColor, textColor, text, show].join(",")}]";

  @override
  int get hashCode => hashObjects([
        bgColor,
        textColor,
        text,
        show,
      ]);
}

// class ListStyle {
//   ListStyle() {
//     throw UnimplementedError();
//   }
// }
