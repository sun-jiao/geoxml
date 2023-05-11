import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'gpx_object.dart';
import 'gpx_tag.dart';
import 'link.dart';
import 'wpt.dart';

/// Rte represents route - an ordered list of waypoints representing a series of
/// turn points leading to a destination.
class Rte extends GpxObject{
  /// GPS name of route.
  String? name;

  /// GPS comment for route.
  String? cmt;

  /// Text description of route for user. Not sent to GPS.
  String? desc;

  /// Source of data. Included to give user some idea of reliability and
  /// accuracy of data.
  String? src;

  /// Links to external information about the route.
  List<Link> links;

  /// GPS route number.
  int? number;

  /// Type (classification) of route.
  String? type;

  /// You can add extend GPX by adding your own elements from another schema
  /// here.
  Map<String, String> extensions;

  // Element tag.
  String tag = GpxTagV11.route;

  /// A list of route points.
  List<Wpt> rtepts;

  /// Construct a new [Rte] object.
  Rte(
      {this.name,
      this.cmt,
      this.desc,
      this.src,
      List<Link>? links,
      this.number,
      this.type,
      Map<String, String>? extensions,
      List<Wpt>? rtepts})
      : links = links ?? [],
        extensions = extensions ?? <String, String>{},
        rtepts = rtepts ?? [];

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is Rte) {
      return other.name == name &&
          other.cmt == cmt &&
          other.desc == desc &&
          other.src == src &&
          const ListEquality().equals(other.links, links) &&
          other.number == number &&
          other.type == type &&
          const MapEquality().equals(other.extensions, extensions) &&
          const ListEquality().equals(other.rtepts, rtepts);
    }

    return false;
  }

  @override
  String toString() => "Rte[${[name, type, extensions, rtepts].join(",")}]";

  @override
  int get hashCode => hashObjects([
        name,
        cmt,
        desc,
        src,
        ...links,
        number,
        type,
        ...extensions.keys,
        ...extensions.values,
        ...rtepts
      ]);
}
