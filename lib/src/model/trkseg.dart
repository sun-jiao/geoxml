import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'wpt.dart';

/// A Track Segment holds a list of Track Points which are logically connected
/// in order. To represent a single GPS track where GPS reception was lost, or
/// the GPS receiver was turned off, start a new Track Segment for each
/// continuous span of track data.
class Trkseg {
  /// List of trak points. A Track Point holds the coordinates, elevation,
  /// timestamp, and metadata for a single point in a track.
  List<Wpt> trkpts;

  /// You can add extend GPX by adding your own elements from another schema
  /// here.
  Map<String, String> extensions;

  /// Construct a new [Trkseg] object.
  Trkseg({List<Wpt> trkpts, Map<String, String> extensions})
      : trkpts = trkpts ?? [],
        extensions = extensions ?? <String, String>{};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is Trkseg) {
      return const ListEquality().equals(other.trkpts, trkpts) &&
          const MapEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  String toString() => "Trkseg[${[trkpts, extensions].join(",")}]";

  @override
  int get hashCode => hashObjects([trkpts, extensions]);
}
