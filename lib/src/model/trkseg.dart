import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'wpt.dart';

// @TODO add extensions;
class Trkseg {
  List<Wpt> trkpts;

  Trkseg({List<Wpt> trkpts}) : trkpts = trkpts ?? [];

  @override
  bool operator ==(other) {
    if (other is Trkseg) {
      return ListEquality().equals(other.trkpts, this.trkpts);
    }

    return false;
  }

  @override
  String toString() {
    return "Trkseg[${[trkpts].join(",")}]";
  }

  @override
  int get hashCode {
    return hashObjects([trkpts]);
  }
}
