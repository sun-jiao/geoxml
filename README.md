geoxml
======

[![Pub Package](https://img.shields.io/pub/v/geoxml.svg)](https://pub.dev/packages/geoxml)
[![Coverage Status](https://coveralls.io/repos/github/sun-jiao/geoxml/badge.svg?branch=main)](https://coveralls.io/github/sun-jiao/geoxml?branch=main)
[![GitHub Issues](https://img.shields.io/github/issues/sun-jiao/geoxml.svg?branch=master)](https://github.com/sun-jiao/geoxml/issues)
[![GitHub Forks](https://img.shields.io/github/forks/sun-jiao/geoxml.svg?branch=master)](https://github.com/sun-jiao/geoxml/network)
[![GitHub Stars](https://img.shields.io/github/stars/sun-jiao/geoxml.svg?branch=master)](https://github.com/sun-jiao/geoxml/stargazers)
[![GitHub License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://raw.githubusercontent.com/sun-jiao/geoxml/master/LICENSE)

A library for loading, manipulating, and saving GPS data in XML format, including GPX 
(https://www.topografix.com/gpx.asp, a light-weight XML data format for the interchange of
GPS data - waypoints, routes, and tracks) and KML (a file format used to display geographic 
data in an Earth browser such as Google Earth).

View the official GPX 1.1 Schema at https://www.topografix.com/GPX/1/1/gpx.xsd .
And for KML schema, see https://developers.google.com/kml/ .

The project is originally authored by @kb0 with others, thanks for their works.

## Getting Started

In your dart/flutter project add the dependency:

```
 dependencies:
   ...
   geoxml: ^2.4.0
```

### Reading GPX

To read GPX input use the GpxReader object and function `Gpx fromString(String input)`:

```dart
import 'package:geoxml/geoxml.dart';

main() async {
  // create gpx from xml string
  var xmlGpx = await GpxReader().fromString('<?xml version="1.0" encoding="UTF-8"?>'
      '<gpx version="1.1" creator="dart-gpx library">'
      '<wpt lat="-25.7996" lon="-62.8666"><ele>10.0</ele><name>Monte Quemado</name><desc>Argentina</desc></wpt>'
      '</gpx>');

  print(xmlGpx);
  print(xmlGpx.wpts);
}
```

To read GPX from a `Stream<String>`:

```dart
import 'package:geoxml/geoxml.dart';

main() async {
  // create gpx from xml string stream
  final stream = File('test/assets/wpt.gpx').openRead()
      .transform(utf8.decoder);
  final kml = await KmlReader()
      .fromStream(stream);

  print(xmlGpx);
  print(xmlGpx.wpts);
}
```

### Writing GPX

To write object to GPX use the GpxWriter object and
function `String asString(Gpx gpx, {bool pretty = false})`:

```dart
import 'package:geoxml/geoxml.dart';

main() {
  // create gpx object
  var gpx = Gpx();
  gpx.creator = "dart-gpx library";
  gpx.wpts = [
    Wpt(lat: 36.62, lon: 101.77, ele: 10.0, name: 'Xining', desc: 'China'),
  ];

  // generate xml string
  var gpxString = GpxWriter().asString(gpx, pretty: true);
  print(gpxString);
}
```

### Reading KML

To read KML input use the KmlReader object and function `Gpx fromString(String input)`:

```dart
import 'package:geoxml/geoxml.dart';

main() async {
  // create gpx from xml string
  var xmlGpx = await KmlReader().fromString('<?xml version="1.0" encoding="UTF-8"?> '
      '<kml xmlns="http://www.opengis.net/kml/2.2"><Document><Placemark><name>Monte Quemado</name>'
      '<description>Argentina</description> <ExtendedData/>'
      '<Point><altitudeMode>absolute</altitudeMode>'
      '<coordinates>-62.8666,-25.7996,10.0</coordinates></Point></Placemark>'
      '</Document></kml>');

  print(xmlGpx);
  print(xmlGpx.wpts);
}
```

To read KML from a `Stream<String>`:

```dart
import 'package:geoxml/geoxml.dart';

main() async {
  // create gpx from xml string stream
  final stream = File('test/assets/wpt.kml').openRead()
      .transform(utf8.decoder);
  final kml = await KmlReader()
      .fromStream(stream);

  print(xmlGpx);
  print(xmlGpx.wpts);
}
```

### Writing KML

To export object to KML use the KmlWriter object and
function `String asString(Gpx gpx, {bool pretty = false})`:

```dart
import 'package:geoxml/geoxml.dart';

main() {
  // create gpx object
  var gpx = Gpx();
  gpx.creator = "dart-gpx library";
  gpx.wpts = [
    Wpt(lat: 36.62, lon: 101.77, ele: 10.0, name: 'Xining', desc: 'China'),
  ];

  // generate xml string
  var kmlString = KmlWriter().asString(gpx, pretty: true);
  print(kmlString);

  // generate xml string with altitude mode - clampToGround
  var kmlString = KmlWriter(altitudeMode: AltitudeMode.clampToGround)
      .asString(gpx, pretty: true);
  print(kmlString);
}
```

## Limitations

This is just an initial version of the package. There are still some limitations:

- No support for GPX 1.0.
- Doesn't validate schema declarations.
- Only some common KML elements are supported.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/sun-jiao/geoxml/issues

### License

The Apache 2.0 License, see [LICENSE](https://github.com/sunjiao/geoxml/raw/master/LICENSE).
