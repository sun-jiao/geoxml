import 'package:quiver/core.dart';

import 'email.dart';
import 'link.dart';

class Person {
  String name;
  Email email;
  Link link;

  Person({this.name, this.email, this.link});

  @override
  bool operator ==(other) {
    if (other is Person) {
      return other.name == this.name && other.email == this.email && other.link == this.link;
    }

    return false;
  }

  @override
  String toString() {
    return "Metadata[${[name, email, link].join(",")}]";
  }

  @override
  int get hashCode {
    return hashObjects([name, email, link]);
  }
}
