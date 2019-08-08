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
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is Metadata) {
      return other.name == name &&
          other.desc == desc &&
          other.author == author &&
          other.copyright == copyright &&
          const ListEquality().equals(other.links, links) &&
          other.time == time &&
          other.keywords == keywords &&
          other.bounds == bounds;
    }

    return false;
  }

  @override
  String toString() =>
      "Metadata[${[name, author, copyright, time, bounds].join(",")}]";

  @override
  int get hashCode => hashObjects(
      [name, desc, author, copyright, links, time, keywords, bounds]);
}
