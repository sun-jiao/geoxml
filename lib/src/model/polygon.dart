import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'geo_object.dart';
import 'geo_style.dart';
import 'kml_tag.dart';
import 'link.dart';
import 'rte.dart';
import 'trk.dart';

/// Polygon represents a simple polygon -
/// an ordered list of points describing a shape.
class Polygon implements GeoObject {
  /// Name of Polygon.
  @override
  String? name;

  /// GPS comment for track.
  @override
  String? cmt;

  /// User description of track.
  @override
  String? desc;

  /// Source of data. Included to give user some idea of reliability and
  /// accuracy of data.
  @override
  String? src;

  /// Links to external information about the track.
  @override
  List<Link> links;

  /// GPS track number.
  @override
  int? number;

  /// Type (classification) of track.
  @override
  String? type;

  /// You can add extend GPX by adding your own elements from another schema
  /// here.
  @override
  Map<String, String> extensions;

  // Element tag.
  @override
  String tag = KmlTag.polygon;

  @override
  GeoStyle? style;

  @override
  bool? extrude;

  bool? tessellate;

  @override
  AltitudeMode? altitudeMode;

  Rte outerBoundaryIs = Rte();

  List<Rte> innerBoundaryIs;

  /// Construct a new [Trk] object.
  Polygon({
    this.name,
    this.cmt,
    this.desc,
    this.src,
    List<Link>? links,
    this.number,
    this.type,
    Map<String, String>? extensions,
    this.extrude,
    this.tessellate,
    this.altitudeMode,
    Rte? outerBoundaryIs,
    List<Rte>? innerBoundaryIs,
  })  : links = links ?? [],
        extensions = extensions ?? <String, String>{},
        outerBoundaryIs = outerBoundaryIs ?? Rte(),
        innerBoundaryIs = innerBoundaryIs ?? [];

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is Polygon) {
      return other.name == name &&
          other.cmt == cmt &&
          other.desc == desc &&
          other.src == src &&
          const ListEquality().equals(other.links, links) &&
          other.number == number &&
          other.type == type &&
          const MapEquality().equals(other.extensions, extensions) &&
          other.style == style &&
          other.extrude == extrude &&
          other.tessellate == tessellate &&
          other.altitudeMode == altitudeMode &&
          other.outerBoundaryIs == outerBoundaryIs &&
          const ListEquality().equals(other.innerBoundaryIs, innerBoundaryIs);
    }

    return false;
  }

  @override
  String toString() => "Polygon[${[
        name,
        type,
        extensions,
        style,
        extrude,
        tessellate,
        altitudeMode,
        outerBoundaryIs,
        innerBoundaryIs
      ].join(",")}]";

  @override
  int get hashCode => hashObjects([
        name,
        cmt,
        desc,
        src,
        number,
        type,
        extrude,
        tessellate,
        altitudeMode,
        outerBoundaryIs,
        ...links,
        ...extensions.keys,
        ...extensions.values,
        ...innerBoundaryIs
      ]);
}
