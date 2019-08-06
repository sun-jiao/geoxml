import 'package:quiver/core.dart';

class Link {
  String href;
  String text;
  String type;

  Link({this.href = '', this.text, this.type});

  @override
  bool operator ==(other) {
    // ignore: type_annotate_public_apis
    if (other is Link) {
      return other.href == href && other.text == text && other.type == type;
    }

    return false;
  }

  @override
  String toString() => "Link[${[href].join(",")}]";

  @override
  int get hashCode => hashObjects([href, text, type]);
}
