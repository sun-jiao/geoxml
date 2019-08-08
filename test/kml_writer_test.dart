library gpx.test.kml_writer_test;

import 'dart:io';

import 'package:gpx/gpx.dart';
import 'package:gpx/src/kml_writer.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('write kml with multiply points', () async {
    final gpx = createGPXWithWpt();
    final xml = await File('test/assets/wpt.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });

  test('write kml with multiply routes', () async {
    final gpx = createGPXWithRte();
    final xml = await File('test/assets/rte.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });

  test('write kml with multiply tracks', () async {
    final gpx = createGPXWithTrk();
    final xml = await File('test/assets/trk.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });

  test('write complex kml', () async {
    final gpx = createComplexGPX();
    final xml = await File('test/assets/complex.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });

  test('write large kml', () async {
    final gpx = GpxReader()
        .fromString(await File('test/assets/large.gpx').readAsString());
    final xml = await File('test/assets/large.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });
}
