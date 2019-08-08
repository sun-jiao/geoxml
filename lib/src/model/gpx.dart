import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'metadata.dart';
import 'rte.dart';
import 'trk.dart';
import 'wpt.dart';

// @TODO add extensions;
class Gpx {
  String version = '1.1';
  String creator = '';
  Metadata metadata;
  List<Wpt> wpts = [];
  List<Rte> rtes = [];
  List<Trk> trks = [];

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
          const ListEquality().equals(other.trks, trks);
    }

    return false;
  }

  @override
  String toString() =>
      "Gpx[${[version, creator, metadata, wpts, rtes, trks].join(",")}]";

  @override
  int get hashCode =>
      hashObjects([version, creator, metadata, wpts, rtes, trks]);
}

class Pt {
  double lat = 0;
  double lon = 0;
  double ele;
  DateTime time;
}
