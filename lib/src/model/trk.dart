import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'link.dart';
import 'trkseg.dart';

class Trk {
  String name;
  String cmt;
  String desc;
  String src;
  List<Link> links;
  int number;
  String type;

  Map<String, String> extensions;

  List<Trkseg> trksegs;

  Trk(
      {this.name,
      this.cmt,
      this.desc,
      this.src,
      List<Link> links,
      this.number,
      this.type,
      Map<String, String> extensions,
      List<Trkseg> trksegs})
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
  int get hashCode => hashObjects(
      [name, cmt, desc, src, links, number, type, extensions, trksegs]);
}
