import 'package:quiver/core.dart';

class Bounds {
  double minlat;
  double minlon;
  double maxlat;
  double maxlon;

  Bounds({this.minlat = 0.0, this.minlon = 0.0, this.maxlat = 0.0, this.maxlon = 0.0});

  @override
  bool operator ==(other) {
    // ignore: type_annotate_public_apis
    if (other is Bounds) {
      return other.minlat == minlat && other.minlon == minlon && other.maxlat == maxlat && other.maxlon == maxlon;
    }

    return false;
  }

  @override
  String toString() => "Bounds[${[minlat, minlon, maxlat, maxlon].join(",")}]";

  @override
  int get hashCode => hashObjects([minlat, minlon, maxlat, maxlon]);
}
