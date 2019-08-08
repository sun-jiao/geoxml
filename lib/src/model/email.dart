import 'package:quiver/core.dart';

class Email {
  String id;
  String domain;

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
