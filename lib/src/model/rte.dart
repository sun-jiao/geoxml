import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'link.dart';
import 'wpt.dart';

// @TODO add extensions;
class Rte {
  String name;
  String cmt;
  String desc;
  String src;
  List<Link> links;
  int number;
  String type;

  List<Wpt> rtepts;

  Rte({this.name, this.cmt, this.desc, this.src, List<Link> links, this.number, this.type, List<Wpt> rtepts})
      : links = links ?? [],
        rtepts = rtepts ?? [];

  @override
  bool operator ==(other) {
    if (other is Rte) {
      return other.name == this.name &&
          other.cmt == this.cmt &&
          other.desc == this.desc &&
          other.src == this.src &&
          ListEquality().equals(other.links, this.links) &&
          other.number == this.number &&
          other.type == this.type &&
          ListEquality().equals(other.rtepts, this.rtepts);
    }

    return false;
  }

  @override
  String toString() {
    return "Rte[${[name, type, rtepts].join(",")}]";
  }

  @override
  int get hashCode {
    return hashObjects([name, cmt, desc, src, links, number, type, rtepts]);
  }
}
