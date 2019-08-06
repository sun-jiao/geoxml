# gpx

A library for or load, manipulate, and save GPS data in GPX format (https://www.topografix.com/gpx.asp, a light-weight XML data format for the interchange of GPS data - waypoints, routes, and tracks).
View the official GPX 1.1 Schema at https://www.topografix.com/GPX/1/1/gpx.xsd.

This library currently 

## Getting Started

In your dart/flutter project add the dependency:

```
 dependencies:
   ...
   gpx: ^0.0.1
```

### Reading XML

To read XML input use the GpxReader object and function `Gpx fromString(String input)`:

```dart
import 'package:gpx/gpx.dart';

main() {
  // create gpx from xml string
  var xmlGpx = GpxReader().fromString('<?xml version="1.0" encoding="UTF-8"?>'
      '<gpx version="1.1" creator="dart-gpx library">'
      '<wpt lat="-25.7996" lon="-62.8666"><ele>10.0</ele><name>Monte Quemado</name><desc>Argentina</desc></wpt>'
      '</gpx>');

  print(xmlGpx);
  print(xmlGpx.wpts);
}
```

### Writing XML

To write object to XML use the GpxWriter object and function `String asString(Gpx gpx, {bool pretty = false})`:

```dart
import 'package:gpx/gpx.dart';

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


## Limitations

This is just an initial version of the package. There are still some limitations:

- No support for 'extension' tag.
- No support for GPX 1.0.
- Read/write only from strings.
- Doesn't validate schema declarations.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/kb0/dart-gpx/issues

### License

The Apache 2.0 License, see [LICENSE](https://github.com/kb0/dart-gpx/raw/master/LICENSE).