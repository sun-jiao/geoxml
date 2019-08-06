import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'bounds.dart';
import 'copyright.dart';
import 'link.dart';
import 'person.dart';

// @TODO add extensions;
class Metadata {
  String name;
  String desc;
  Person author;
  Copyright copyright;
  List<Link> links;
  DateTime time;
  String keywords;
  Bounds bounds;

  Metadata({
    this.name,
    this.desc,
    this.author,
    this.copyright,
    List<Link> links,
    this.time,
    this.keywords,
    this.bounds,
  }) : links = links ?? [];

  @override
  bool operator ==(other) {
    if (other is Metadata) {
      return other.name == this.name &&
          other.desc == this.desc &&
          other.author == this.author &&
          other.copyright == this.copyright &&
          ListEquality().equals(other.links, this.links) &&
          other.time == this.time &&
          other.keywords == this.keywords &&
          other.bounds == this.bounds;
    }

    return false;
  }

  @override
  String toString() {
    return "Metadata[${[name, author, copyright, time, bounds].join(",")}]";
  }

  @override
  int get hashCode {
    return hashObjects([name, desc, author, copyright, links, time, keywords, bounds]);
  }
}
