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

  Trk(
      {this.name,
      this.cmt,
      this.desc,
      this.src,
      List<Link> links,
      this.number,
      this.type,
      List<Trkseg> trksegs})
      : links = links ?? [],
        trksegs = trksegs ?? [];

  @override
  bool operator ==(other) {
    // ignore: type_annotate_public_apis
    if (other is Trk) {
      return other.name == name &&
          other.cmt == cmt &&
          other.desc == desc &&
          other.src == src &&
          const ListEquality().equals(other.links, links) &&
          other.number == number &&
          other.type == type &&
          const ListEquality().equals(other.trksegs, trksegs);
    }

    return false;
  }

  @override
  String toString() => "Trk[${[name, type, trksegs].join(",")}]";

  @override
  int get hashCode =>
      hashObjects([name, cmt, desc, src, links, number, type, trksegs]);
}
