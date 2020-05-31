import 'package:gpx/gpx.dart';

void main() {
  // create gpx-xml from object
  final gpx = Gpx();
  gpx.version = '1.1';
  gpx.creator = 'dart-gpx library';
  gpx.metadata = Metadata();
  gpx.metadata.name = 'world cities';
  gpx.metadata.desc = 'location of some of world cities';
  gpx.metadata.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  gpx.wpts = [
    Wpt(
        lat: -25.7996,
        lon: -62.8666,
        ele: 10.1,
        name: 'Monte Quemado',
        desc: 'Argentina'),
    Wpt(
        lat: 36.62,
        lon: 101.77,
        ele: 10.1,
        name: 'Xining',
        desc: 'China',
        extensions: {'test_key': 'test_value', 'test_key_2': 'test_value_2'}),
  ];

  // get GPX string
  final gpxString = GpxWriter().asString(gpx, pretty: true);
  print(gpxString);

  // export gpx object into kml
  final kmlString = KmlWriter().asString(gpx, pretty: true);
  print(kmlString);

  // read gpx from gpx-xml string
  final xmlGpx = GpxReader().fromString('<?xml version="1.0" encoding="UTF-8"?>'
      '<gpx version="1.1" creator="dart-gpx library">'
      '<metadata>'
      '<name>world cities</name>'
      '<time>2010-01-02T03:04:05.000Z</time>'
      '</metadata>'
      '<wpt lat="-25.7996" lon="-62.8666"><ele>10.0</ele><name>Monte Quemado</name><desc>Argentina</desc></wpt>'
      '</gpx>');
  print(xmlGpx);
}
