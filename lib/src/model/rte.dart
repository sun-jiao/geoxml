import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'link.dart';
import 'wpt.dart';

class Rte {
  String name;
  String cmt;
  String desc;
  String src;
  List<Link> links;
  int number;
  String type;

  Map<String, String> extensions;

  List<Wpt> rtepts;

  Rte(
      {this.name,
      this.cmt,
      this.desc,
      this.src,
      List<Link> links,
      this.number,
      this.type,
      Map<String, String> extensions,
      List<Wpt> rtepts})
      : links = links ?? [],
        extensions = extensions ?? <String, String>{},
        rtepts = rtepts ?? [];

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is Rte) {
      return other.name == name &&
          other.cmt == cmt &&
          other.desc == desc &&
          other.src == src &&
          const ListEquality().equals(other.links, links) &&
          other.number == number &&
          other.type == type &&
          const MapEquality().equals(other.extensions, extensions) &&
          const ListEquality().equals(other.rtepts, rtepts);
    }

    return false;
  }

  @override
  String toString() => "Rte[${[name, type, extensions, rtepts].join(",")}]";

  @override
  int get hashCode => hashObjects(
      [name, cmt, desc, src, links, number, type, extensions, rtepts]);
}
