import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'wpt.dart';

// @TODO add extensions;
class Trkseg {
  List<Wpt> trkpts;

  Trkseg({List<Wpt> trkpts}) : trkpts = trkpts ?? [];

  @override
  bool operator ==(other) {
    // ignore: type_annotate_public_apis
    if (other is Trkseg) {
      return const ListEquality().equals(other.trkpts, trkpts);
    }

    return false;
  }

  @override
  String toString() => "Trkseg[${[trkpts].join(",")}]";

  @override
  int get hashCode => hashObjects([trkpts]);
}
