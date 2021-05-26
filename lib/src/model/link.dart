import 'package:quiver/core.dart';

/// A link to an external resource (Web page, digital photo, video clip, etc)
/// with additional information.
class Link {
  /// URL of hyperlink.
  String href;

  /// Text of hyperlink.
  String? text;

  /// Mime type of content (image/jpeg).
  String? type;

  /// Construct a new [Link] object.
  Link({this.href = '', this.text, this.type});

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
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
