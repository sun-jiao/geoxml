import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'link.dart';
import 'trkseg.dart';

// @TODO add extensions;
class Trk {
  String name;
  String cmt;
  String desc;
  String src;
  List<Link> links;
  int number;
  String type;
  List<Trkseg> trksegs;

  Trk({this.name, this.cmt, this.desc, this.src, List<Link> links, this.number, this.type, List<Trkseg> trksegs})
      : links = links ?? [],
        trksegs = trksegs ?? [];

  @override
  bool operator ==(other) {
    if (other is Trk) {
      return other.name == this.name &&
          other.cmt == this.cmt &&
          other.desc == this.desc &&
          other.src == this.src &&
          ListEquality().equals(other.links, this.links) &&
          other.number == this.number &&
          other.type == this.type &&
          ListEquality().equals(other.trksegs, this.trksegs);
    }

    return false;
  }

  @override
  String toString() {
    return "Trk[${[name, type, trksegs].join(",")}]";
  }

  @override
  int get hashCode {
    return hashObjects([name, cmt, desc, src, links, number, type, trksegs]);
  }
}
