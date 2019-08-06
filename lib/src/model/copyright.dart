import 'package:quiver/core.dart';

class Copyright {
  String author = "";
  int year;
  String license;

  Copyright({this.author = "", this.year, this.license});

  @override
  bool operator ==(other) {
    if (other is Copyright) {
      return other.author == this.author && other.year == this.year && other.license == this.license;
    }

    return false;
  }

  @override
  String toString() {
    return "Copyright[${[author, year, license].join(",")}]";
  }

  @override
  int get hashCode {
    return hashObjects([author, year, license]);
  }
}
