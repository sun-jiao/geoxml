import 'package:quiver/core.dart';

class Link {
  String href;
  String text;
  String type;

  Link({this.href = "", this.text, this.type});

  @override
  bool operator ==(other) {
    if (other is Link) {
      return other.href == this.href && other.text == this.text && other.type == this.type;
    }

    return false;
  }

  @override
  String toString() {
    return "Link[${[href].join(",")}]";
  }

  @override
  int get hashCode {
    return hashObjects([href, text, type]);
  }
}
