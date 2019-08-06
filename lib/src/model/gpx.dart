import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'metadata.dart';
import 'rte.dart';
import 'trk.dart';
import 'wpt.dart';

// @TODO add extensions;
class Gpx {
  String version = "1.1";
  String creator = "";
  Metadata metadata;
  List<Wpt> wpts = [];
  List<Rte> rtes = [];
  List<Trk> trks = [];

  @override
  bool operator ==(other) {
    if (other is Gpx) {
      return other.creator == this.creator &&
          other.version == this.version &&
          other.metadata == this.metadata &&
          ListEquality().equals(other.wpts, this.wpts) &&
          ListEquality().equals(other.rtes, this.rtes) &&
          ListEquality().equals(other.trks, this.trks);
    }

    return false;
  }

  @override
  String toString() {
    return "Gpx[${[version, creator, metadata, wpts, rtes, trks].join(",")}]";
  }

  @override
  int get hashCode {
    return hashObjects([version, creator, metadata, wpts, rtes, trks]);
  }
}

class Pt {
  double lat = 0.0;
  double lon = 0.0;
  double ele;
  DateTime time;
}
