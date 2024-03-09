import 'geo_style.dart';
import 'link.dart';

class GeoObject {
  /// GPS name of object.
  String? name;

  /// GPS comment for object.
  String? cmt;

  /// User description of object.
  String? desc;

  /// Source of data. Included to give user some idea of reliability and
  /// accuracy of data.
  String? src;

  /// Links to external information about the object.
  List<Link> links = [];

  /// GPS track number.
  int? number;

  /// Type (classification) of object.
  String? type;

  /// You can add extend GPX by adding your own elements from another schema
  /// here.
  Map<String, String> extensions = {};

  /// Element tag.
  late String tag;

  /// Kml style
  GeoStyle? style;

  bool? extrude;

  AltitudeMode? altitudeMode;
}

enum AltitudeMode {
  clampToGround,
  relativeToGround,
  absolute,
  relativeToSeaFloor,
  clampToSeaFloor,
}
