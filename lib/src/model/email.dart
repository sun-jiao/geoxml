import 'package:quiver/core.dart';

class Email {
  String id;
  String domain;

  Email({this.id = "", this.domain = ""});

  @override
  bool operator ==(other) {
    if (other is Email) {
      return other.id == this.id && other.domain == this.domain;
    }

    return false;
  }

  @override
  String toString() {
    return "Email[${[id, domain].join(",")}]";
  }

  @override
  int get hashCode {
    return hashObjects([id, domain]);
  }
}
