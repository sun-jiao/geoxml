import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'metadata.dart';
import 'rte.dart';
import 'trk.dart';
import 'wpt.dart';

/// GPX documents contain a metadata header, followed by waypoints, routes, and
/// tracks. You can add your own elements to the extensions section of the GPX
/// document.
class Gpx {
  /// Version number of your GPX document.
  String version = '1.1';

  /// The name or URL of the software that created your GPX document. This
  /// allows others to inform the creator of a GPX instance document that fails
  /// to validate.
  String creator = '';

  /// Metadata about the file.
  Metadata metadata;

  /// A list of waypoints.
  List<Wpt> wpts = [];

  /// A list of routes.
  List<Rte> rtes = [];

  /// A list of tracks.
  List<Trk> trks = [];

  /// You can add extend GPX by adding your own elements from another schema
  /// here.
  Map<String, String> extensions = {};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is Gpx) {
      return other.creator == creator &&
          other.version == version &&
          other.metadata == metadata &&
          const ListEquality().equals(other.wpts, wpts) &&
          const ListEquality().equals(other.rtes, rtes) &&
          const ListEquality().equals(other.trks, trks) &&
          const MapEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  String toString() => "Gpx[${[
        version,
        creator,
        metadata,
        wpts,
        rtes,
        trks,
        extensions
      ].join(",")}]";

  @override
  int get hashCode =>
      hashObjects([version, creator, metadata, wpts, rtes, trks, extensions]);
}

class Pt {
  double lat = 0;
  double lon = 0;
  double ele;
  DateTime time;
}
