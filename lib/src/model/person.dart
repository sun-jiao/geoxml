import 'package:quiver/core.dart';

import 'email.dart';
import 'link.dart';

class Person {
  String name;
  Email email;
  Link link;

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
