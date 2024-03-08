import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import '../gpx_reader.dart';
import '../gpx_writer.dart';
import '../kml_reader.dart';
import '../kml_writer.dart';
import 'geo_style.dart';
import 'metadata.dart';
import 'rte.dart';
import 'trk.dart';
import 'wpt.dart';

/// GPX documents contain a metadata header, followed by waypoints, routes, and
/// tracks. You can add your own elements to the extensions section of the GPX
/// document.
class GeoXml {
  /// Version number of your GPX document.
  String version = '1.1';

  /// The name or URL of the software that created your GPX document. This
  /// allows others to inform the creator of a GPX instance document that fails
  /// to validate.
  String creator = '';

  /// Metadata about the file.
  Metadata? metadata;

  /// A list of waypoints.
  List<Wpt> wpts = [];

  /// A list of routes.
  List<Rte> rtes = [];

  /// A list of tracks.
  List<Trk> trks = [];

  List<GeoStyle> styles = [];

  /// You can add extend GPX by adding your own elements from another schema
  /// here.
  Map<String, String> extensions = {};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GeoXml) {
      return other.creator == creator &&
          other.version == version &&
          other.metadata == metadata &&
          const ListEquality().equals(other.wpts, wpts) &&
          const ListEquality().equals(other.rtes, rtes) &&
          const ListEquality().equals(other.trks, trks) &&
          const ListEquality().equals(other.styles, styles) &&
          const MapEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  String toString() => "GeoXml[${[
        version,
        creator,
        metadata,
        wpts,
        rtes,
        trks,
        styles,
        extensions
      ].join(",")}]";

  @override
  int get hashCode => hashObjects([
        version,
        creator,
        metadata,
        ...extensions.keys,
        ...extensions.values,
        ...trks,
        ...rtes,
        ...wpts,
        ...styles
      ]);

  String toGpxString({bool pretty = false}) =>
      GpxWriter().asString(this, pretty: pretty);

  String toKmlString(
          {bool pretty = false,
          AltitudeMode altitudeMode = AltitudeMode.absolute}) =>
      KmlWriter(altitudeMode: altitudeMode).asString(this, pretty: pretty);

  static Future<GeoXml> fromKmlString(String str) =>
      KmlReader().fromString(str);

  static Future<GeoXml> fromKmlStream(Stream<String> stream) =>
      KmlReader().fromStream(stream);

  static Future<GeoXml> fromGpxString(String str) =>
      GpxReader().fromString(str);

  static Future<GeoXml> fromGpxStream(Stream<String> stream) =>
      GpxReader().fromStream(stream);
}

@Deprecated('Use `GeoXml` instead.')
class Gpx extends GeoXml {}
