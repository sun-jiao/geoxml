import 'package:quiver/core.dart';

/// Information about the copyright holder and any license governing use of this
/// file. By linking to an appropriate license, you may place your data into the
/// public domain or grant additional usage rights.
class Copyright {
  /// Copyright holder.
  String author = '';

  /// Year of copyright.
  int? year;

  /// Link to external file containing license text.
  String? license;

  /// Construct a new [Copyright] with author, year and license.
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
