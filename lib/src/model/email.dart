import 'package:quiver/core.dart';

/// An email address. Broken into two parts (id and domain) to help prevent
/// email harvesting.
class Email {
  String id;
  String domain;

  /// Construct a new [Email] with id and domain.
  Email({this.id = '', this.domain = ''});

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is Email) {
      return other.id == id && other.domain == domain;
    }

    return false;
  }

  @override
  String toString() => "Email[${[id, domain].join(",")}]";

  @override
  int get hashCode => hashObjects([id, domain]);
}
