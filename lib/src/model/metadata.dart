import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'bounds.dart';
import 'copyright.dart';
import 'link.dart';
import 'person.dart';

/// Information about the GPX file, author, and copyright restrictions goes in
/// the metadata section. Providing rich, meaningful information about your GPX
/// files allows others to search for and use your GPS data.
class Metadata {
  /// The name of the GPX file.
  String? name;

  /// A description of the contents of the GPX file.
  String? desc;

  /// The person or organization who created the GPX file.
  Person? author;

  /// Copyright and license information governing use of the file.
  Copyright? copyright;

  /// URLs associated with the location described in the file.
  List<Link> links;

  /// The creation date of the file.
  DateTime? time;

  /// Keywords associated with the file. Search engines or databases can use
  /// this information to classify the data.
  String? keywords;

  /// Minimum and maximum coordinates which describe the extent of the
  /// coordinates in the file.
  Bounds? bounds;

  /// You can add extend GPX by adding your own elements from another schema
  /// here.
  Map<String, String> extensions = {};

  /// Construct a new [Metadata] object.
  Metadata(
      {this.name,
      this.desc,
      this.author,
      this.copyright,
      List<Link>? links,
      this.time,
      this.keywords,
      this.bounds,
      Map<String, String>? extensions})
      : links = links ?? [],
        extensions = extensions ?? <String, String>{};

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
          other.bounds == bounds &&
          const MapEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  String toString() => "Metadata[${[
        name,
        author,
        copyright,
        time,
        bounds,
        extensions
      ].join(",")}]";

  @override
  int get hashCode => hashObjects([
        name,
        desc,
        author,
        copyright,
        ...links,
        time,
        keywords,
        bounds,
        ...extensions.keys,
        ...extensions.values
      ]);
}
