import 'package:quiver/core.dart';

import 'email.dart';
import 'link.dart';

/// A person or organization.
class Person {
  /// Name of person or organization.
  String? name;

  /// Email address.
  Email? email;

  /// Link to Web site or other external information about person
  Link? link;

  /// Construct a new [Person] object.
  Person({this.name, this.email, this.link});

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is Person) {
      return other.name == name && other.email == email && other.link == link;
    }

    return false;
  }

  @override
  String toString() => "Person[${[name, email, link].join(",")}]";

  @override
  int get hashCode => hashObjects([name, email, link]);
}
