library gpx.test.writer_test;

import 'dart:io';

import 'package:gpx/gpx.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('write gpx with multiply points', () async {
    var gpx = createGPXWithWpt();
    var xml = await File('test/assets/wpt.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write gpx with multiply routes', () async {
    var gpx = createGPXWithRte();
    var xml = await File('test/assets/rte.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write gpx with multiply tracks', () async {
    var gpx = createGPXWithTrk();
    var xml = await File('test/assets/trk.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write complex gpx', () async {
    var gpx = createComplexGPX();
    var xml = await File('test/assets/complex.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });
}
