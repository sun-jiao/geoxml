import 'package:quiver/core.dart';

class Copyright {
  String author = '';
  int year;
  String license;

  Copyright({this.author = '', this.year, this.license});

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is Copyright) {
      return other.author == author &&
          other.year == year &&
          other.license == license;
    }

    return false;
  }

  @override
  String toString() => "Copyright[${[author, year, license].join(",")}]";

  @override
  int get hashCode => hashObjects([author, year, license]);
}
