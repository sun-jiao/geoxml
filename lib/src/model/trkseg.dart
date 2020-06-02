import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'wpt.dart';

class Trkseg {
  List<Wpt> trkpts;
  Map<String, String> extensions;

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
