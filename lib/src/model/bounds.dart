import 'package:quiver/core.dart';

class Bounds {
  double minlat;
  double minlon;
  double maxlat;
  double maxlon;

  Bounds({this.minlat = 0.0, this.minlon = 0.0, this.maxlat = 0.0, this.maxlon = 0.0});

  @override
  bool operator ==(other) {
    if (other is Bounds) {
      return other.minlat == this.minlat &&
          other.minlon == this.minlon &&
          other.maxlat == this.maxlat &&
          other.maxlon == this.maxlon;
    }

    return false;
  }

  @override
  String toString() {
    return "Bounds[${[minlat, minlon, maxlat, maxlon].join(",")}]";
  }

  @override
  int get hashCode {
    return hashObjects([minlat, minlon, maxlat, maxlon]);
  }
}
