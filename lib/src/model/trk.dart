import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'gpx_object.dart';
import 'gpx_tag.dart';
import 'link.dart';
import 'trkseg.dart';

/// Trk represents a track - an ordered list of points describing a path.
class Trk extends GpxObject {
  /// GPS name of track.
  String? name;

  /// GPS comment for track.
  String? cmt;

  /// User description of track.
  String? desc;

  /// Source of data. Included to give user some idea of reliability and
  /// accuracy of data.
  String? src;

  /// Links to external information about the track.
  List<Link> links;

  /// GPS track number.
  int? number;

  /// Type (classification) of track.
  String? type;

  /// You can add extend GPX by adding your own elements from another schema
  /// here.
  Map<String, String> extensions;

  // Element tag.
  String tag = GpxTagV11.track;

  /// A Track Segment holds a list of Track Points which are logically connected
  /// in order. To represent a single GPS track where GPS reception was lost, or
  /// the GPS receiver was turned off, start a new Track Segment for each
  /// continuous span of track data.
  List<Trkseg> trksegs;

  /// Construct a new [Trk] object.
  Trk(
      {this.name,
      this.cmt,
      this.desc,
      this.src,
      List<Link>? links,
      this.number,
      this.type,
      Map<String, String>? extensions,
      List<Trkseg>? trksegs})
      : links = links ?? [],
        extensions = extensions ?? <String, String>{},
        trksegs = trksegs ?? [];

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is Trk) {
      return other.name == name &&
          other.cmt == cmt &&
          other.desc == desc &&
          other.src == src &&
          const ListEquality().equals(other.links, links) &&
          other.number == number &&
          other.type == type &&
          const MapEquality().equals(other.extensions, extensions) &&
          const ListEquality().equals(other.trksegs, trksegs);
    }

    return false;
  }

  @override
  String toString() => "Trk[${[name, type, extensions, trksegs].join(",")}]";

  @override
  int get hashCode => hashObjects([
        name,
        cmt,
        desc,
        src,
        number,
        type,
        ...links,
        ...extensions.keys,
        ...extensions.values,
        ...trksegs
      ]);
}
