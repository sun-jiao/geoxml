import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'geo_object.dart';
import 'geo_style.dart';
import 'gpx_tag.dart';
import 'link.dart';

enum FixType { fix_2d, fix_3d, dgps, none, pps, unknown }

/// Wpt represents a waypoint, point of interest, or named feature on a map.
class Wpt implements GeoObject {
  /// The latitude of the point. This is always in decimal degrees, and always
  /// in WGS84 datum.
  double? lat;

  /// The longitude of the point. This is always in decimal degrees, and always
  /// in WGS84 datum.
  double? lon;

  /// The elevation (in meters) of the point.
  double? ele;

  /// The time that the point was recorded.
  DateTime? time;

  /// Magnetic variation (in degrees) at the point.
  double? magvar;

  /// Height (in meters) of geoid (mean sea level) above WGS84 earth ellipsoid.
  /// As defined in NMEA GGA message.
  double? geoidheight;

  /// The GPS name of the waypoint. This field will be transferred to and from
  /// the GPS. GPX does not place restrictions on the length of this field or
  /// the characters contained in it. It is up to the receiving application to
  /// validate the field before sending it to the GPS.
  @override
  String? name;

  /// GPS waypoint comment. Sent to GPS as comment.
  @override
  String? cmt;

  /// A text description of the element. Holds additional information about the
  /// element intended for the user, not the GPS.
  @override
  String? desc;

  /// Source of data. Included to give user some idea of reliability and
  /// accuracy of data. "Garmin eTrex", "USGS quad Boston North", e.g.
  @override
  String? src;

  /// Links to external information.
  @override
  List<Link> links;

  /// Text of GPS symbol name. For interchange with other programs, use the
  /// exact spelling of the symbol as displayed on the GPS. If the GPS
  /// abbreviates words, spell them out
  String? sym;

  /// Type (classification) of the waypoint.
  @override
  String? type;

  /// Type of GPX fix.
  FixType? fix;

  /// Number of satellites used to calculate the GPX fix.
  int? sat;

  /// Horizontal dilution of precision.
  double? hdop;

  /// Vertical dilution of precision.
  double? vdop;

  /// Position dilution of precision.
  double? pdop;

  /// Number of seconds since last DGPS update.
  double? ageofdgpsdata;

  /// ID of DGPS station used in differential correction.
  int? dgpsid;

  @override
  AltitudeMode? altitudeMode;

  @override
  bool? extrude;

  @override
  GeoStyle? style;

  /// You can add extend GPX by adding your own elements from another schema
  /// here.
  @override
  Map<String, String> extensions;

  /// Construct a new [Wpt] object.
  Wpt(
      {this.lat = 0.0,
      this.lon = 0.0,
      this.ele,
      this.time,
      this.magvar,
      this.geoidheight,
      this.name,
      this.cmt,
      this.desc,
      this.src,
      List<Link>? links,
      this.sym,
      this.type,
      this.fix,
      this.sat,
      this.hdop,
      this.vdop,
      this.pdop,
      this.ageofdgpsdata,
      this.dgpsid,
      Map<String, String>? extensions})
      : links = links ?? [],
        extensions = extensions ?? <String, String>{};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is Wpt) {
      return other.lat == lat &&
          other.lon == lon &&
          other.ele == ele &&
          other.time == time &&
          other.magvar == magvar &&
          other.geoidheight == geoidheight &&
          other.name == name &&
          other.cmt == cmt &&
          other.desc == desc &&
          other.src == src &&
          const ListEquality().equals(other.links, links) &&
          other.sym == sym &&
          other.type == type &&
          other.fix == fix &&
          other.sat == sat &&
          other.hdop == hdop &&
          other.vdop == vdop &&
          other.pdop == pdop &&
          other.ageofdgpsdata == ageofdgpsdata &&
          other.dgpsid == dgpsid &&
          other.style == style &&
          other.extrude == extrude &&
          other.altitudeMode == altitudeMode &&
          const MapEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  bool coordinateEqual(Wpt other) =>
      other.lat == lat && other.lon == lon && other.ele == ele;

  @override
  String toString() =>
      "Wpt[${[
        lat,
        lon,
        ele,
        time,
        name,
        src,
        style,
        extrude,
        altitudeMode,
        extensions,
      ].join(",")}]";

  @override
  int get hashCode => hashObjects([
        lat,
        lon,
        ele,
        time,
        magvar,
        geoidheight,
        name,
        cmt,
        desc,
        src,
        ...links,
        sym,
        type,
        fix,
        sat,
        hdop,
        vdop,
        pdop,
        ageofdgpsdata,
        dgpsid,
        style,
        extrude,
        altitudeMode,
        ...extensions.keys,
        ...extensions.values
      ]);

  @override
  int? number;

  @override
  String tag = GpxTag.wayPoint;
}
