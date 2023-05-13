## [2.5.0]

* support writing to kml with `<gx:Track>`.

## [2.4.0]

* class `Gpx` was renamed to `GeoXml`.
* added methods `toGpxString` and `toKmlString` to `GeoXml`.
* added static methods `fromKmlString`, `fromKmlStream`, `fromGpxString` and `fromGpxStream` to `GeoXml`.

## [2.3.0]

* added `KmlReader` to load KML file.
* added `fromStream()` in `GpxReader` and `KmlReader` for reading from stream.
* `fromString()` was changed to an async method.

## [2.2.1]

* fixed missed symbol during writing

## [2.2.0]

* update Dart SDK to 2.17.0 or later
* update XML to 6.1.0
* fix reading with missing tags (version, creator)

## [2.1.1]

* Fix GpxReader to read CDATA elements

## [2.1.0]

* Add option to KmlWriter to specify <altitudeMode> (absolute, clampToGround, relativeToGround)

## [2.0.0]

* BREAKING CHANGE: This version requires Dart SDK 2.12.0 or later (null safety).
* update XML to min v5.0.0

## [1.1.1]

* fix hashCode calculation for gpx types
* update Dart SDK requirements to min. v2.3.0

## [1.1.0]

* fix gps fixing tag (FixType - 2d, 3d, dgps, none, pps)

## [1.0.1+3]

* add comments for GPX fields

## [1.0.1+2]

* update Xml package to 4.3.0
* add comments

## [1.0.1+1]

* fix formatting

## [1.0.1]

* fix kml writer for empty metadata

## [1.0.0]

* add extensions support
* fix person tag
* add wpt.ageofdgpsdata, wpt.geoidheight, wpt.dgpsid, wpt.fix, wpt.sym

## [0.0.4]

* add wpt.extensions support

## [0.0.3]

* fix lint issues
* add kml writer (export from Gpx into KML)

## [0.0.2]

* fix lint issues

## [0.0.1]

* Initial release - reader, writer for GPX-files
